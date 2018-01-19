//
//  CityWeatherController.swift
//  Weather
//
//  Created by user134583 on 1/18/18.
//  Copyright © 2018 user134583. All rights reserved.
//

import UIKit

class CityWeatherController: UIViewController {
    //iz-za togo, chto ya zdes inicializiroval chezez (), fetch ne rabotal. zaprosi k bd crashilis'
    var cityWeather : CityWeather?

    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var coordLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        windLabel.text = "\(String(format: "%.2f", cityWeather!.wind)) m/s"
        minTempLabel.text = "\(String(format: "%.2f", cityWeather!.minTemp-273))°C"
        maxTempLabel.text = "\(String(format: "%.2f", cityWeather!.maxTemp-273))°C"
        tempLabel.text = "\(String(format: "%.2f", cityWeather!.temp-273))°C"
        cityNameLabel.text = cityWeather!.name
        coordLabel.text = "(\(cityWeather!.coord!.lat);\(cityWeather!.coord!.lon))"
    }
}
