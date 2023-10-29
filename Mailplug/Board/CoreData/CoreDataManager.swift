import CoreData
import UIKit
import Combine
import Foundation

class CoreDataManager {
    
    static var shared = CoreDataManager()
    
    @Published var recentSearchs: [RecentSearchModel] = []
    
    /// container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("persistentContainer Error! \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    /// context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// entity
    var entity: NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: "RecentSearch", in: context)
    }
    
    /// context 저장
    func saveToContext() {
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchRecentSearch() -> [RecentSearch] {
        do {
            let request = RecentSearch.fetchRequest()
            let results = try context.fetch(request)
            return results
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
}

extension CoreDataManager {
    
    /// get 최근검색
    func getRecentSearch() {
        var mySearchs: [RecentSearchModel] = []
        let fetchResults = fetchRecentSearch()
        for result in fetchResults {
            let recentSearch = RecentSearchModel(searchType: result.searchType ?? "", content: result.content ?? "", searchTime: result.searchTime ?? Date())
            mySearchs.append(recentSearch)
        }
        mySearchs.sort(by: { $0.searchTime > $1.searchTime})
        self.recentSearchs = mySearchs
    }
    
    /// insert & update
    func saveORUpdate(_ recentSearch: RecentSearchModel) {
        guard let entity = entity else { return }
        let filter = filterSameData(sumTypeContent: recentSearch.sumTypeContent)
        do {
            let datas = try context.fetch(filter) as! [NSManagedObject] /// datas에는 만약 똑같은 키워드를 가진 데이터가 있다면 값이 담기고 없다면 빈배열이 담깁니다
            var cell: RecentSearch! = nil
            if datas.count == 0 { // 검색된 데이터가 없는경우
                cell = NSManagedObject(entity: entity, insertInto: context) as? RecentSearch /// 새로운 셀생성
            } else { /// 검색된 데이터가 있는경우 검색된 데이터를 호출
                cell = datas.first as? RecentSearch
            }
            cell.content = recentSearch.content
            cell.searchTime = recentSearch.searchTime
            cell.searchType = recentSearch.searchType
            cell.sumTypeContent = recentSearch.sumTypeContent
        } catch {
            print("Failed")
        }
        saveToContext()
        getRecentSearch()
    }
    
    /// delete 최근검색
    func deleteRecentSearch(_ recentSearch: RecentSearchModel) {
        let fetchResults = fetchRecentSearch()
        let recentSearchCell = fetchResults.filter { $0.sumTypeContent == recentSearch.sumTypeContent }
        context.delete(recentSearchCell[0])
        self.recentSearchs.removeAll { $0.sumTypeContent == recentSearch.sumTypeContent }
        saveToContext()
    }
}

extension CoreDataManager {

    /// 중복된 데이터를 찾음
    fileprivate func filterSameData(sumTypeContent: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest<NSFetchRequestResult>(entityName: "RecentSearch")
        fetchRequest.predicate = NSPredicate(format: "sumTypeContent = %@", "\(sumTypeContent)")
        return fetchRequest
    }
}
