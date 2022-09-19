//
//  TasksList.swift
//  RealmApp
//
//  Created by Illya Gurkov on 13.09.22.
//

import Foundation
import RealmSwift

class TasksList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}
