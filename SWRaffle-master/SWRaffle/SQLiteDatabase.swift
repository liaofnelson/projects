//
//  SQLiteDatabase.swift
//  Tutorial5
//
//  Created by Lindsay Wells (updated 2020).
//
//  You are welcome to use this class in your assignments, but you will need to modify it in order for
//  it to do anything!
//
//  Add your code to the end of this class for handling individual tables
//
//  Known issues: doesn't handle versioning and changing of table structure.
//

import Foundation
import SQLite3

class SQLiteDatabase
{
    /* This variable is of type OpaquePointer, which is effectively the same as a C pointer (recall the SQLite API is a C-library). The variable is declared as an optional, since it is possible that a database connection is not made successfully, and will be nil until such time as we create the connection.*/
    private var db: OpaquePointer?
    
    /* Change this value whenever you make a change to table structure.
        When a version change is detected, the updateDatabase() function is called,
        which in turn calls the createTables() function.
     
        WARNING: DOING THIS WILL WIPE YOUR DATA, unless you modify how updateDatabase() works.
     */
    private let DATABASE_VERSION = 2
    
    
    
    // Constructor, Initializes a new connection to the database
    /* This code checks for the existence of a file within the application’s document directory with the name <dbName>.sqlite. If the file doesn’t exist, it attempts to create it for us. Since our application has the ability to write into this directory, this should happen the first time that we run the application without fail (it can still possibly fail if the device is out of storage space).
     The remainder of the function checks to see if we are able to open a successful connection to this database file using the sqlite3_open() function. With all of the SQLite functions we will be using, we can check for success by checking for a return value of SQLITE_OK.
     */
    init(databaseName dbName:String)
    {
        //get a file handle somewhere on this device
        //(if it doesn't exist, this should create the file for us)
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(dbName).sqlite")
        
        //try and open the file path as a database
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            print("Successfully opened connection to database at \(fileURL.path)")
            self.dbName = dbName
            checkForUpgrade();
        }
        else
        {
            print("Unable to open database at \(fileURL.path)")
            printCurrentSQLErrorMessage(db)
        }
        
    }
    
    deinit
    {
        /* We should clean up our memory usage whenever the object is deinitialized, */
        sqlite3_close(db)
    }
    private func printCurrentSQLErrorMessage(_ db: OpaquePointer?)
    {
        let errorMessage = String.init(cString: sqlite3_errmsg(db))
        print("Error:\(errorMessage)")
    }
    
    private func createTables()
    {
        //INSERT YOUR createTable function calls here
        //e.g. createRaffleTable()
        createRaffleTable()
        createTicketTable()
        createCustomerTable()
    }
    private func dropTables()
    {
        //INSERT YOUR dropTable function calls here
        //e.g. dropTable(tableName:"Raffle")
        dropTable(tableName:"Raffle")
        dropTable(tableName:"Ticket")
        dropTable(tableName:"Customer")
    }
    
    /* --------------------------------*/
    /* ----- VERSIONING FUNCTIONS -----*/
    /* --------------------------------*/
    private var dbName:String = ""
    func checkForUpgrade()
    {
        // get the current version number
        let defaults = UserDefaults.standard
        let lastSavedVersion = defaults.integer(forKey: "DATABASE_VERSION_\(dbName)")
        
        // detect a version change
        if (DATABASE_VERSION > lastSavedVersion)
        {
            onUpdateDatabase(previousVersion:lastSavedVersion, newVersion: DATABASE_VERSION);
            
            // set the stored version number
            defaults.set(DATABASE_VERSION, forKey: "DATABASE_VERSION_\(dbName)")
        }
    }
    
    func onUpdateDatabase(previousVersion : Int, newVersion : Int)
    {
        print("Detected Database Version Change (was:\(previousVersion), now:\(newVersion))")
        
        //handle the change (simple version)
        dropTables()
        createTables()
    }
    
    
    
    /* --------------------------------*/
    /* ------- HELPER FUNCTIONS -------*/
    /* --------------------------------*/
    
    /* Pass this function a CREATE sql string, and a table name, and it will create a table
        You should call this function from createTables()
     */
    private func createTableWithQuery(_ createTableQuery:String, tableName:String)
    {
        /*
         1.    sqlite3_prepare_v2()
         2.    sqlite3_step()
         3.    sqlite3_finalize()
         */
        //prepare the statement
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK
        {
            //execute the statement
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("\(tableName) table created.")
            }
            else
            {
                print("\(tableName) table could not be created.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else
        {
            print("CREATE TABLE statement for \(tableName) could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        
        //clean up
        sqlite3_finalize(createTableStatement)
        
    }
    /* Pass this function a table name.
        You should call this function from dropTables()
     */
    private func dropTable(tableName:String)
    {
        /*
         1.    sqlite3_prepare_v2()
         2.    sqlite3_step()
         3.    sqlite3_finalize()
         */
        
        //prepare the statement
        let query = "DROP TABLE IF EXISTS \(tableName)"
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil)     == SQLITE_OK
        {
            //run the query
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(tableName) table deleted.")
            }
        }
        else
        {
            print("\(tableName) table could not be deleted.")
            printCurrentSQLErrorMessage(db)
        }
        
        //clear up
        sqlite3_finalize(statement)
    }
    
    //helper function for handling INSERT statements
    //provide it with a binding function for replacing the ?'s for setting values
    private func insertWithQuery(_ insertStatementQuery : String, bindingFunction:(_ insertStatement: OpaquePointer?)->())
    {
        /*
         Similar to the CREATE statement, the INSERT statement needs the following SQLite functions to be called (note the addition of the binding function calls):
         1.    sqlite3_prepare_v2()
         2.    sqlite3_bind_***()
         3.    sqlite3_step()
         4.    sqlite3_finalize()
         */
        // First, we prepare the statement, and check that this was successful. The result will be a C-
        // pointer to the statement:
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementQuery, -1, &insertStatement, nil) == SQLITE_OK
        {
            //handle bindings
            bindingFunction(insertStatement)
            
            /* Using the pointer to the statement, we can call the sqlite3_step() function. Again, we only
             step once. We check that this was successful */
            //execute the statement
            if sqlite3_step(insertStatement) == SQLITE_DONE
            {
                print("Successfully inserted row.")
            }
            else
            {
                print("Could not insert row.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else
        {
            print("INSERT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
    
        //clean up
        sqlite3_finalize(insertStatement)
    }
    
    //helper function to run delete statements.
    //Provide it with a binding function for replacing the "?"'s in the WHERE clause
    private func deleteWithQuery(
        _ deleteStatementQuery : String,
        bindingFunction: ((_ rowHandle: OpaquePointer?)->()))
    {
        //prepare the statement
        var deleteStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, deleteStatementQuery, -1, &deleteStatement, nil) == SQLITE_OK
        {
            //do bindings
            bindingFunction(deleteStatement)
            
            //execute
            if sqlite3_step(deleteStatement) == SQLITE_DONE
            {
                print("Successfully deleded row.")
            }
            else
            {
                print("Could not delete row.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else
        {
            print("DELETE statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        //clean up
        sqlite3_finalize(deleteStatement)
    }

    //helper function to run Select statements
    //provide it with a function to do *something* with each returned row
    //(optionally) Provide it with a binding function for replacing the "?"'s in the WHERE clause
    private func selectWithQuery(
        _ selectStatementQuery : String,
        eachRow: (_ rowHandle: OpaquePointer?)->(),
        bindingFunction: ((_ rowHandle: OpaquePointer?)->())? = nil)
    {
        //prepare the statement
        var selectStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectStatementQuery, -1, &selectStatement, nil) == SQLITE_OK
        {
            //do bindings, only if we have a bindingFunction set
            //hint, to do selectRaffleBy(id:) you will need to set a bindingFunction (if you don't hardcode the id)
            bindingFunction?(selectStatement)
            
            //iterate over the result
            while sqlite3_step(selectStatement) == SQLITE_ROW
            {
                eachRow(selectStatement);
            }
            
        }
        else
        {
            print("SELECT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        //clean up
        sqlite3_finalize(selectStatement)
    }
    
    //helper function to run update statements.
    //Provide it with a binding function for replacing the "?"'s in the WHERE clause
    private func updateWithQuery(
        _ updateStatementQuery : String,
        bindingFunction: ((_ rowHandle: OpaquePointer?)->()))
    {
        //prepare the statement
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementQuery, -1, &updateStatement, nil) == SQLITE_OK
        {
            //do bindings
            bindingFunction(updateStatement)
            
            //execute
            if sqlite3_step(updateStatement) == SQLITE_DONE
            {
                print("Successfully updated row.")
            }
            else
            {
                print("Could not update row.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else
        {
            print("UPDATE statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        //clean up
        sqlite3_finalize(updateStatement)
    }
    
    /* --------------------------------*/
    /* --- ADD YOUR TABLES ETC HERE ---*/
    /* --------------------------------*/
    
    // MARK: - Raffle Table
    func createRaffleTable() {
        let createRafflesTableQuery = """
            CREATE TABLE Raffle (
                ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                Name CHAR(255),
                Price REAL,
                Stock INTEGER,
                MaximumNumber INTEGER,
                PurchaseLimit INTEGER,
                Description CHAR(255),
                Wallpaper MEDIUMTEXT,
                IsMarginRaffle INTEGER
            );
            """
        
        createTableWithQuery(createRafflesTableQuery, tableName: "Raffle")
    }
    
    func insert(raffle:SWRaffle) {
        let insertStatementQuery = "INSERT INTO Raffle (Name, Price, Stock, MaximumNumber, PurchaseLimit, Description, Wallpaper, IsMarginRaffle) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string:raffle.name).utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 2, raffle.price)
            sqlite3_bind_int(insertStatement, 3, raffle.stock)
            sqlite3_bind_int(insertStatement, 4, raffle.maximumNumber)
            sqlite3_bind_int(insertStatement, 5, raffle.purchaseLimit)
            sqlite3_bind_text(insertStatement, 6, NSString(string:raffle.description).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, NSString(string:raffle.wallpaperData.base64EncodedString()).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 8, raffle.isMarginRaffle)
        })
    }
    
    func delete(raffle:SWRaffle) {
        let deleteStatementQuery = "DELETE FROM Raffle WHERE id = ?"
        deleteWithQuery(deleteStatementQuery, bindingFunction: { (deleteStatement) in
            sqlite3_bind_int(deleteStatement, 1, raffle.ID)
        })
    }
    
    func update(raffle:SWRaffle) {
        let updateStatementQuery = "UPDATE Raffle set name = ?, price = ?, stock = ?, maximumNumber = ?, purchaseLimit = ?, description = ?, wallpaper = ?, isMarginRaffle = ? WHERE id = ?"
        updateWithQuery(updateStatementQuery, bindingFunction: { (updateStatement) in
            sqlite3_bind_text(updateStatement, 1, NSString(string:raffle.name).utf8String, -1, nil)
            sqlite3_bind_double(updateStatement, 2, raffle.price)
            sqlite3_bind_int(updateStatement, 3, raffle.stock)
            sqlite3_bind_int(updateStatement, 4, raffle.maximumNumber)
            sqlite3_bind_int(updateStatement, 5, raffle.purchaseLimit)
            sqlite3_bind_text(updateStatement, 6, NSString(string:raffle.description).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 7, NSString(string:raffle.wallpaperData.base64EncodedString()).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 8, raffle.isMarginRaffle)
            sqlite3_bind_int(updateStatement, 9, raffle.ID)
        })
    }
    
    func selectAllRaffles() -> [SWRaffle] {
        var result = [SWRaffle]()
        let selectStatementQuery = "SELECT id, name, price, stock, maximumNumber, purchaseLimit, description, wallpaper, isMarginRaffle FROM Raffle"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            
            //create a raffle object from each result
            let raffle = SWRaffle(
                ID: sqlite3_column_int(row, 0),
                name: String(cString:sqlite3_column_text(row, 1)),
                price: sqlite3_column_double(row, 2),
                stock: sqlite3_column_int(row, 3),
                maximumNumber: sqlite3_column_int(row, 4),
                purchaseLimit: sqlite3_column_int(row, 5),
                description: String(cString:sqlite3_column_text(row, 6)),
                wallpaperData: Data(base64Encoded: String(cString:sqlite3_column_text(row, 7)), options: .ignoreUnknownCharacters)!,
                isMarginRaffle: sqlite3_column_int(row, 8)
                )
            //add it to the result array
            result.insert(raffle, at: 0)
        })
        return result
    }
    
    func selectRaffleBy(id:Int32) -> SWRaffle? {
        var result : SWRaffle?
        let selectStatementQuery = "SELECT id, name, price, stock, maximumNumber, purchaseLimit, description, wallpaper, isMarginRaffle FROM Raffle WHERE id = ?"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            result = SWRaffle(
                ID: id,
                name: String(cString:sqlite3_column_text(row, 1)),
                price: sqlite3_column_double(row, 2),
                stock: sqlite3_column_int(row, 3),
                maximumNumber: sqlite3_column_int(row, 4),
                purchaseLimit: sqlite3_column_int(row, 5),
                description: String(cString:sqlite3_column_text(row, 6)),
                wallpaperData: Data(base64Encoded: String(cString:sqlite3_column_text(row, 7)), options: .ignoreUnknownCharacters)!,
                isMarginRaffle: sqlite3_column_int(row, 8)
            )
        }, bindingFunction: { (selectStatement) in
            sqlite3_bind_int(selectStatement, 1, id)
        })
        return result
    }
    
    // MARK: - Ticket Table
    
    func createTicketTable() {
        let createTicketsTableQuery = """
            CREATE TABLE Ticket (
                RaffleID INTEGER,
                TicketNumber INTEGER,
                TicketPrice REAL,
                CustomerName CHAR(255),
                IsSold INTEGER,
                PurchaseTime CHAR(255)
            );
            """
        
        createTableWithQuery(createTicketsTableQuery, tableName: "Ticket")
    }
    
    // for creating a raffle
    func insert(ticket:SWTicket) {
        let insertStatementQuery = "INSERT INTO Ticket (RaffleID, TicketNumber, TicketPrice, CustomerName, IsSold, PurchaseTime) VALUES (?, ?, ?, ?, ?, ?)"
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_int(insertStatement, 1, ticket.raffleID)
            sqlite3_bind_int(insertStatement, 2, ticket.ticketNumber)
            sqlite3_bind_double(insertStatement, 3, ticket.ticketPrice)
            sqlite3_bind_text(insertStatement, 4, NSString(string:ticket.customerName).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 5, ticket.isSold)
            sqlite3_bind_text(insertStatement, 6, NSString(string:ticket.purchaseTime).utf8String, -1, nil)
        })
    }
    
    // for deleting a raffle
    func delete(raffleID:Int32, ticketNumber:Int32) {
        let deleteStatementQuery = "DELETE FROM Ticket WHERE raffleID = ? AND ticketNumber = ?"
        deleteWithQuery(deleteStatementQuery, bindingFunction: { (deleteStatement) in
            sqlite3_bind_int(deleteStatement, 1, raffleID)
            sqlite3_bind_int(deleteStatement, 2, ticketNumber)
        })
    }
          
    // for selling tickets
    func update(ticket:SWTicket) {
        let updateStatementQuery = "UPDATE Ticket set customerName = ?, isSold = ?, purchaseTime = ? WHERE raffleID = ? AND ticketNumber = ?"
        updateWithQuery(updateStatementQuery, bindingFunction: { (updateStatement) in
            sqlite3_bind_text(updateStatement, 1, NSString(string:ticket.customerName).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 2, ticket.isSold)
            sqlite3_bind_text(updateStatement, 3, NSString(string:ticket.purchaseTime).utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 4, ticket.raffleID)
            sqlite3_bind_int(updateStatement, 5, ticket.ticketNumber)
        })
    }
    
    // unused
    func selectAllTickets() -> [SWTicket] {
        var result = [SWTicket]()
        let selectStatementQuery = "SELECT raffleID, ticketNumber, ticketPrice, customerName, isSold, purchaseTime FROM Ticket"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            
            //create a ticket object from each result
            let ticket = SWTicket(
                raffleID: sqlite3_column_int(row, 0),
                ticketNumber: sqlite3_column_int(row, 1),
                ticketPrice: sqlite3_column_double(row, 2),
                customerName: String(cString:sqlite3_column_text(row, 3)),
                isSold: sqlite3_column_int(row, 4),
                purchaseTime: String(cString:sqlite3_column_text(row, 5))
                )
            //add it to the result array
            result.append(ticket)
        })
        return result
    }
        
    // for selling tickets & drawing the winner from a normal raffle
    func selectAllTicketsBy(raffleID:Int32, isSold:Int32) -> [SWTicket] {
        var result = [SWTicket]()
        let selectStatementQuery = "SELECT raffleID, ticketNumber, ticketPrice, customerName, isSold, purchaseTime FROM Ticket WHERE raffleID = ? AND isSold = ?"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            
            //create a ticket object from each result
            let ticket = SWTicket(
                raffleID: sqlite3_column_int(row, 0),
                ticketNumber: sqlite3_column_int(row, 1),
                ticketPrice: sqlite3_column_double(row, 2),
                customerName: String(cString:sqlite3_column_text(row, 3)),
                isSold: sqlite3_column_int(row, 4),
                purchaseTime: String(cString:sqlite3_column_text(row, 5))
                )
            //add it to the result array
            result.append(ticket)
        }, bindingFunction: { (selectStatement) in
            sqlite3_bind_int(selectStatement, 1, raffleID)
            sqlite3_bind_int(selectStatement, 2, isSold)
        })
        return result
    }

    // for drawing the winner from a margin raffle
    func selectTicketBy(raffleID:Int32, ticketNumber:Int32) -> SWTicket? {
        var result : SWTicket?
        let selectStatementQuery = "SELECT raffleID, ticketNumber, ticketPrice, customerName, isSold, purchaseTime FROM Ticket WHERE raffleID = ? AND ticketNumber = ?"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            result = SWTicket(
                raffleID: sqlite3_column_int(row, 0),
                ticketNumber: sqlite3_column_int(row, 1),
                ticketPrice: sqlite3_column_double(row, 2),
                customerName: String(cString:sqlite3_column_text(row, 3)),
                isSold: sqlite3_column_int(row, 4),
                purchaseTime: String(cString:sqlite3_column_text(row, 5))
            )
        }, bindingFunction: { (selectStatement) in
            sqlite3_bind_int(selectStatement, 1, raffleID)
            sqlite3_bind_int(selectStatement, 2, ticketNumber)
        })
        return result
    }
    
    // MARK: - Customer Table
    func createCustomerTable() {
        let createCustomersTableQuery = """
            CREATE TABLE Customer (
                Name CHAR(255),
                PurchaseTimes INTEGER
            );
            """
        
        createTableWithQuery(createCustomersTableQuery, tableName: "Customer")
    }
    
    func insert(customer:SWCustomer) {
        let insertStatementQuery = "INSERT INTO Customer (Name, PurchaseTimes) VALUES (?, ?)"
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string:customer.name.trimmingCharacters(in: CharacterSet.whitespaces)).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, customer.purchaseTimes)
        })
    }
        
    func update(customer:SWCustomer) {
        let updateStatementQuery = "UPDATE Customer set purchaseTimes = ? WHERE name = ?"
        updateWithQuery(updateStatementQuery, bindingFunction: { (updateStatement) in
            sqlite3_bind_int(updateStatement, 1, customer.purchaseTimes)
            sqlite3_bind_text(updateStatement, 2, NSString(string:customer.name.trimmingCharacters(in: CharacterSet.whitespaces)).utf8String, -1, nil)
        })
    }
    
    func selectAllCustomers() -> [SWCustomer] {
        var result = [SWCustomer]()
        let selectStatementQuery = "SELECT name, purchaseTimes FROM Customer"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            
            //create a raffle object from each result
            let customer = SWCustomer(
                name: String(cString:sqlite3_column_text(row, 0)),
                purchaseTimes: sqlite3_column_int(row, 1)
                )
            //add it to the result array
            result.insert(customer, at: 0)
        })
        return result
    }
    
    func selectFrequentCustomers() -> [SWCustomer] {
        var result = [SWCustomer]()
        let selectStatementQuery = "SELECT name, purchaseTimes FROM Customer ORDER BY purchaseTimes"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            
            //create a raffle object from each result
            let customer = SWCustomer(
                name: String(cString:sqlite3_column_text(row, 0)),
                purchaseTimes: sqlite3_column_int(row, 1)
                )
            //add it to the result array
            result.insert(customer, at: 0)
        })
        return result
    }

    
    func selectCustomerBy(name:String) -> SWCustomer? {
        var result : SWCustomer?
        let selectStatementQuery = "SELECT name, purchaseTimes FROM Customer WHERE name = ?"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in
            result = SWCustomer(
                name: String(cString:sqlite3_column_text(row, 0)),
                purchaseTimes: sqlite3_column_int(row, 1)
            )
        }, bindingFunction: { (selectStatement) in
            sqlite3_bind_text(selectStatement, 1, NSString(string:name.trimmingCharacters(in: CharacterSet.whitespaces)).utf8String, -1, nil)
        })
        return result
    }

}
