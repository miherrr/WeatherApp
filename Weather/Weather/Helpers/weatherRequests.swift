//
//  weatherRequests.swift
//  Weather
//
//  Created by user134583 on 1/16/18.
//  Copyright © 2018 user134583. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension ViewController {
    
    static let APPID = "63e0ccba2d645f1397141ebe35d95de2"
    static let baseUri = "http://api.openweathermap.org/data/2.5/"
    
    func UpdateChosenCities() {
        let ids = (self.chosenCities.map{String($0.id)}).joined(separator: ",")
        
        guard let url = URL(string: "\(ViewController.baseUri)/group?id=\(ids)&APPID=\(ViewController.APPID)") else {return}
        
        let session = URLSession.shared
        
        let managedContext = GetObjectManagedContext()
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print(response)
            }
            
            guard let data = data else {return}
            print (data)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print (json)
                
                self.BulkUpdateWeather(data: (json as! [String:Any])["list"] as! [Any], context: managedContext)
                
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
            } catch {
                return
            }
        }.resume()
    }
    
    //Results queqe from requests    
    func GetWeather(forCity: String) {
        guard let url = URL(string: "\(ViewController.baseUri)/weather?q=\(forCity.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&APPID=\(ViewController.APPID)") else {return}
        
        let session = URLSession.shared
        
        let managedContext = GetObjectManagedContext()
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
                print (response)
            }
            
            guard let data = data else {return}
            print (data)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print (json)
                
                guard (json as! [String:Any])["cod"] as? Int32 ?? 0 == 200,
                    let resultCity = self.CreateWeatherObject(data: json as! [String : Any], context: managedContext) else {
                    self.ShowCityNotFoundAlert()
                    return
                }
                
                //Here we update local collection and
                self.chosenCities.append(City(name: resultCity.name!, id: resultCity.cityId))
                //
                
                DispatchQueue.main.async {
                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: self.chosenCities), forKey: "chosenCities")
                    self.tableView.reloadData()
                    
                    if self.chosenCities.count >= ViewController.maxElemsInTable {
                        self.addBtn.isEnabled = false }
                    
                }
            } catch {
                print (error)
            }
        }.resume()
    }
    
    private func CreateWeatherObject(data: [String:Any], context: NSManagedObjectContext) -> CityWeather? {
        let entityWeather = NSEntityDescription.entity(forEntityName: "CityWeather", in: context)
        let entityCoord = NSEntityDescription.entity(forEntityName: "Coordinates", in: context)
        
        let weather = CityWeather(entity: entityWeather!, insertInto: context)
        let coord = Coordinates(entity: entityCoord!, insertInto: context)
        
        weather.cityId = data["id"] as! Int32
        weather.name = data["name"] as? String
        weather.wind = (data["wind"] as! [String:Any])["speed"] as! Double
        weather.temp = (data["main"] as! [String:Any])["temp"] as! Double
        weather.minTemp = (data["main"] as! [String:Any])["temp_min"] as! Double
        weather.maxTemp = (data["main"] as! [String:Any])["temp_max"] as! Double
                
        coord.lon = (data["coord"] as! [String:Any])["lon"] as! Double
        coord.lat = (data["coord"] as! [String:Any])["lat"] as! Double
        
        weather.coord = coord
        
        do {
            try context.save()
            return weather
        } catch let (error){
            print("Could not save \(error)")
        }
        return nil
    }
    
    private func BulkUpdateWeather(data: [Any], context: NSManagedObjectContext) {
        let ids = data.map{($0 as! [String:Any])["id"] as! Int32}
        
        let fetchRequest = NSFetchRequest<CityWeather>(entityName: "CityWeather")
        fetchRequest.predicate = NSPredicate(format: "cityId IN %@", ids)
        
        do {
            let fetchResult = try context.fetch(fetchRequest)
            assert(fetchResult.count == ids.count)
            
            data.forEach {
                let item = $0 as! [String:Any]
                let curCity = fetchResult.first(where: {$0.cityId == item["id"] as! Int32})!
                curCity.temp = (item["main"] as! [String:Any])["temp"] as! Double
                curCity.minTemp = (item["main"] as! [String:Any])["temp_min"] as! Double
                curCity.maxTemp = (item["main"] as! [String:Any])["temp_max"] as! Double
                curCity.wind = (item["wind"] as! [String:Any])["speed"] as! Double
            }
            
            try context.save()
        } catch let (error) {
            print(error)
        }
    }
    
    private func GetObjectManagedContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared
        .delegate as! AppDelegate
        
        let managedContext = appDelegate.persistentContainer.viewContext
        return managedContext
    }
    
    private func ShowCityNotFoundAlert() {
        let alert = UIAlertController(title: "Not found", message: "Entered city was not found", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)    }
}
