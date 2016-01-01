//
//  DetailViewController.swift
//  PeticionServidorTablas
//
//  Created by Josman Perez on 29/12/15.
//  Copyright © 2015 Josman Perez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
  @IBOutlet weak var labelTitulo: UILabel!
  @IBOutlet weak var labelAutores: UILabel!
  @IBOutlet weak var imagenVie: UIImageView!
  
  var nombre:String? = nil
  var autores:String? = nil
  var imagen:UIImage? = nil
  
  var detailItem: AnyObject? {
    didSet {
      // Update the view.
      self.configureView()
    }
  }
  
  func configureView() {
    
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.configureView()
    
    if let nombre = nombre {
      labelTitulo.text = nombre
    }
    if let autores = autores {
      labelAutores.text = autores
    }
    if let imagenF = imagen {
      print("tiene imagen")
      imagenVie.image = imagenF
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

