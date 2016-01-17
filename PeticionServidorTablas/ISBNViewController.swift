//
//  ISBNViewController.swift
//  PeticionServidorTablas
//
//  Created by Josman Perez on 30/12/15.
//  Copyright © 2015 Josman Perez. All rights reserved.
//

import CoreData
import UIKit

protocol communicationWithTableView {
  func passName(name: String,isbn:String,autores:[String],imagen:UIImage?)
}

class ISBNViewController: UIViewController, UITextFieldDelegate {
  
  var isbnLibro:String = ""
  var tituloLibro:String = ""
  var autoresLibro:[String] = []
  var imagenLibro:UIImage?
  
  var autores = ""
  
  var contexto:NSManagedObjectContext?
  
  var mDelegate: communicationWithTableView!
  
  @IBOutlet weak var isbnInputText: UITextField!
  
  @IBOutlet weak var botonAceptar: UIButton!
  @IBOutlet weak var textViewResultado: UITextView!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  let baseURL = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:")
  
  @IBOutlet weak var labelTituloText: UILabel!
  @IBOutlet weak var imagenCover: UIImageView!
  
  var imageCache: NSCache?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    isbnInputText.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  
  @IBAction func btnCancelar() {
    
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func btnAceptar() {
    
    print("comprobar que tengo algo en el modelo");
    let seccionEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
    let peticion = seccionEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("petLibro", substitutionVariables: ["titulo":self.tituloLibro])
    do {
      let seccionEntidad2 = try self.contexto?.executeFetchRequest(peticion!)
      if (seccionEntidad2?.count > 0) {
        print("Ya existe un libro con ese nombre");
      } else {
        print("No existe libro con ese nombre")
        // Guardamos en la base de datos
        let nuevaSeccionEntidad = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
        nuevaSeccionEntidad.setValue(self.tituloLibro, forKey: "titulo")
        if let imagen = imagenLibro {
          nuevaSeccionEntidad.setValue(UIImagePNGRepresentation(imagen), forKey: "imagen")
        } else {
          nuevaSeccionEntidad.setValue(nil, forKey: "imagen")
        }
        nuevaSeccionEntidad.setValue(self.autores, forKey: "autores")
        nuevaSeccionEntidad.setValue(self.isbnLibro, forKey: "isbn")
        do {
          try self.contexto?.save()
        } catch {
          print("error")
        }
      }
      
    } catch {
      
    }
    
    if let texto = labelTituloText.text {
      print("2ºVC: \(texto)")
      self.mDelegate.passName(texto, isbn: isbnLibro, autores: autoresLibro,imagen: imagenLibro)
    } else {
      self.mDelegate.passName("", isbn: "", autores: [],imagen: nil)
    }
    
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
//  func crearImagenesEnt(autores: [String]) -> Set<NSObject> {
//    var entidades = Set<NSObject>()
//    
//    for autor in autores {
//      
//      
//    }
//    
//    
//    return entidades
//  }
  
  // MARK: - Acciones
  
  func textFieldDidEndEditing(textField: UITextField) {
    self.imagenCover.hidden = true
    if (isbnInputText.text?.characters.count > 0) {
      self.isbnLibro = isbnInputText.text!
      self.spinner.startAnimating()
      if let isbn = isbnInputText.text {
        let url = NSURL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)")
        print(url!)
        let sesion = NSURLSession.sharedSession()
        
        let dt = sesion.dataTaskWithURL(url!) {
          (let datos, let resp, let error) in
          if let httpResponse = resp as? NSHTTPURLResponse {
            switch (httpResponse.statusCode) {
            case 200:
              _ = NSString(data: datos!, encoding: NSUTF8StringEncoding)
              //print(texto!)
              var titulo = ""
              do {
                let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableContainers)
                
                let dico1 = json as! NSDictionary
                if let dico2 = dico1["ISBN:\(isbn)"] as? NSDictionary {
                  let dico3 = dico2["authors"] as? [NSDictionary]
                  titulo = "\(dico2["title"] as! NSString as String)"
                  self.tituloLibro = "\(dico2["title"] as! NSString as String)"
                  
                  // Comprobamos que exista portada
                  if let dico4 = dico2["cover"] as? NSDictionary {
                    let url = NSURL(string: dico4["medium"] as! NSString as String)
                    print(url!)
                    //self.imagenActivityIndicator.startAnimating()
                    //self.imagenActivityIndicator.hidden = false
                    self.load_image(url!)
                  }
                  if let dicAutores = dico3 {
                    for autor in dicAutores {
                      self.autores += "\(autor["name"] as! NSString as String) "
                      self.autoresLibro.append("\(autor["name"] as! NSString as String)")
                    }
                  }
                } else {
                  titulo = "ISBN no válido"
                }
              } catch _ {
                print("Error")
              }
              

              
              
              dispatch_async(dispatch_get_main_queue()) {
                print(self.tituloLibro)
                if (self.tituloLibro != "") {
                  self.botonAceptar.hidden = false
                }
                self.spinner.stopAnimating()
                //self.textViewResultado?.text = texto! as String
                self.labelTituloText.text = titulo
                self.textViewResultado!.text = self.autores
              }
            default:
              print("El get no fue satisfactorio")
              
            }
          } else {
            dispatch_async(dispatch_get_main_queue()) {
              self.spinner.stopAnimating()
              let alertController = UIAlertController(title: "Error", message:
                "¡Ha ocurrido un error con internet!", preferredStyle: UIAlertControllerStyle.Alert)
              alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
              
              self.presentViewController(alertController, animated: true, completion: nil)
            }
            
          }
          
        }
        dt.resume()
        
      }
    }
  }
  
  // Ocultar el teclado
  @IBAction func textFieldDoneEditing(sender: UITextField) {
    
    sender.resignFirstResponder()
  }
  
  // Ocultar teclado con toque en la pantalla
  @IBAction func backgroundTap(sender: UIControl) {
    
    isbnInputText.resignFirstResponder()
  }
  
  func load_image(urlString:NSURL) {
    let imgURL = urlString
    let request: NSURLRequest = NSURLRequest(URL: imgURL)
    
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request){
      (data, response, error) -> Void in
      
      if (error == nil && data != nil)
      {
        func display_image()
        {
          self.imagenCover.image = UIImage(data: data!)
          self.imagenCover.hidden = false
          self.imagenLibro = UIImage(data: data!)
          //self.imagenActivityIndicator.hidden = true
          //self.imagenActivityIndicator.stopAnimating()
        }
        
        dispatch_async(dispatch_get_main_queue(), display_image)
      }
      
    }
    
    task.resume()
  }
  
  
}
