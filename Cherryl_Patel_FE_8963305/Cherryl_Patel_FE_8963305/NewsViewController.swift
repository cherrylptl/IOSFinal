import UIKit
import CoreData

class NewsViewController: UIViewController {
    
    @IBOutlet weak var newsTable: UITableView!
    
    @IBAction func homeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func plusButton(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Where would you like to go Enter your new destination here", message: nil, preferredStyle: .alert)
        
        //Alert textfield
        var destinationTextField: UITextField?
        alertController.addTextField { textField in
            textField.placeholder = "Enter new destination"
            destinationTextField = textField
        }
        
        //Alert action button
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let goAction = UIAlertAction(title: "Go", style: .default) { _ in
            if let destination = destinationTextField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                self.getNews(destination)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(goAction)
        present(alertController, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNews("Canada")
        
        // Register NewsTableViewCell from XIB
        let nib = UINib(nibName: "NewsTableViewCell", bundle: nil)
        newsTable.register(nib, forCellReuseIdentifier: NewsTableViewCell.identifier)
        
        // Set delegate and dataSource
        newsTable.delegate = self
        newsTable.dataSource = self
    }
    
    var newsData: NewsModel?
    
    // Get News Data
    func getNews(_ destination: String) {
        guard let url = URL(string: "https://newsapi.org/v2/everything?q=\(destination)&apiKey=ab286084d03345eb88eb9976c7cb7597") else {
            return
        }
        
        print(url)
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error:", error)
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                let newsData = try jsonDecoder.decode(NewsModel.self, from: data)
                
                // Update UI
                DispatchQueue.main.async {
                    self.newsData = newsData
                    self.newsTable.reloadData()
                    // Save the first news data to CoreData
                    if let firstArticle = newsData.articles?.first {
                        self.saveNewsToCoreData(article: firstArticle, cityName: destination)
                    }
                }
            } catch {
                print("Error decoding JSON:", error)
            }
        }
        task.resume()
    }
    
    // Save News Data to CoreData
    func saveNewsToCoreData(article: Article, cityName: String) {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let newsEntity = NSEntityDescription.entity(forEntityName: "News", in: managedContext)!
            
            let newsObject = NSManagedObject(entity: newsEntity, insertInto: managedContext) as! News
            newsObject.author = article.author
            newsObject.cityName = cityName
            newsObject.discription = article.description
            newsObject.source = article.source?.name
            newsObject.title = article.title
            
            // Create or fetch HistoryData
            let historyDataFetchRequest: NSFetchRequest<HistoryData> = HistoryData.fetchRequest()
            historyDataFetchRequest.predicate = NSPredicate(format: "historyID == %@", cityName)
            let historyData: HistoryData
            do {
                let results = try managedContext.fetch(historyDataFetchRequest)
                if let existingHistoryData = results.first {
                    historyData = existingHistoryData
                } else {
                    let newHistoryData = HistoryData(context: managedContext)
                    newHistoryData.historyID = 1
                    historyData = newHistoryData
                }
            } catch {
                print("Error fetching or creating HistoryData:", error)
                return
            }
            
            // Associate News with HistoryData
            newsObject.historyData = historyData
            
            do {
                try managedContext.save()
                print("News saved to CoreData")
            } catch let error as NSError {
                print("Could not save news to CoreData. \(error), \(error.userInfo)")
            }
        }
    }


extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData?.articles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as! NewsTableViewCell
        
        if let article = newsData?.articles?[indexPath.row] {
            cell.configure(
                title: article.title ?? "No Data Found",
                description: article.description ?? "No Data Found",
                source: "Source: \(article.source?.name ?? "No Data Found")",
                author: "Author: \(article.author ?? "No Data Found")"
            )
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
           return UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
       }
}
