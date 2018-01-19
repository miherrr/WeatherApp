//
//  ViewController.swift
//  Weather
//
//  Created by user134583 on 1/15/18.
//  Copyright © 2018 user134583. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    static let maxElemsInTable = 5

    var chosenCities = [City]()
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addBtn: UIBarButtonItem!
    @IBAction func loadAllData(_ sender: Any) {
        //WeatherRequests.GetWeather(forCity: "London")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowCityWeatherSegue",
            let destination = segue.destination as? CityWeatherController,
            let rowIndex = tableView.indexPathForSelectedRow?.row
        else {
            return
        }
        let cityId = chosenCities[rowIndex].id
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<CityWeather>(entityName: "CityWeather")
        fetchRequest.predicate = NSPredicate(format: "cityId = %@", NSNumber(value: Int(cityId)))
        
        do {
            
            let fetchResult = try managedContext.fetch(fetchRequest)
            assert(fetchResult.count < 2)
            
            guard let cityWeather = fetchResult.first
                else {
                    return
            }
            
            //Pass data to segue
            destination.cityWeather = cityWeather
        } catch {
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        guard let data = UserDefaults.standard.object(forKey: "chosenCities") as? NSData,
            let chosenCitiesDefault = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [City]
            else { return }
        
        chosenCities = chosenCitiesDefault
        
        if chosenCities.count >= ViewController.maxElemsInTable {
            addBtn.isEnabled = false
        }
    }
    
    @IBAction func addName(_ sender: Any) {
        let alert = UIAlertController(title: "New city", message: "Add a new city name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) -> Void in
            
            let textField = alert.textFields![0]
            
            let _ = self.GetWeather(forCity: textField.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = "City name"
        })
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.UpdateChosenCities()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Weather"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chosenCities.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowCityWeatherSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! UITableViewCell
        
        let city = chosenCities[indexPath.row]
        cell.textLabel!.text = city.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        chosenCities.remove(at: indexPath.row)
        if chosenCities.count < ViewController.maxElemsInTable {
            addBtn.isEnabled = true
        }
        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: chosenCities), forKey: "chosenCities")
        tableView.reloadData()
    }
}

