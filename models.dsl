workspace {
    model {
        # People/Actors
        # <variable> = person <name> <description> <tag>
        publicUser = person "Public User" "An anonymous user of the bookstore" "User"
        authorizedUser = person "Authorized User" "A registered user of the bookstore, with personal account" "User"
        internalUser = person "Internal User" "An internal user of the bookstore, with administrator privileges" "User"

        # Software Systems
        # <variable> = softwareSystem <name> <description> <tag>
        bookstoreSystem = softwareSystem "Bookstore System" "Allows users to view about book, and administrate the book details" "Target System" {
            # Level 2: Containers
            # <variable> = container <name> <description> <technology> <tag>
            frontStoreApplication = container "Front-store Application" "Provide all the bookstore functionalities to both public and authorized users" "JavaScript & ReactJS"
            backOfficeApplication = container "Back-office Application" "Provide all the bookstore administration functionalities to internal users" "JavaScript & ReactJS"
            searchWebApi = container "Search Web API" "Allows only authorized users searching books records via HTTPS API" "Go"
            adminWebApi = container "Admin Web API" "Allows only internal users administering books details via HTTPS API" "Go" {
                # Level 3: Components
                # <variable> = component <name> <description> <technology> <tag>
                bookService = component "Book Service" "Allows administrating book details" "Go"
                authService = component "Authorizer" "Authorize users by using external Authorization System" "Go"
                bookEventPublisher = component "Book Events Publisher" "Publishes books-related events to Book Event System" "Go"
            }
            publicWebApi = container "Public Web API" "Allows public users getting books information" "Go"
            searchDatabase = container "Search Database" "Stores searchable book information" "ElasticSearch" "Database"
            bookstoreDatabase = container "Bookstore Database" "Stores book details" "PostgreSQL" "Database"
            bookEventSystem = container "Book Event System" "Handles the book published events" "Apache Kafka 3.0"
            bookEventConsumer = container "Book Event Consumer" "Listening to domain events and handle book update events" "Go"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listening to external events from Publisher System, and update book information" "Go"
        }
        
        # External Software Systems
        authSystem = softwareSystem "Authorization System" "The external Identiy Provider System" "External System"
        publisherSystem = softwareSystem "Publisher System" "The 3rd party system of publishers that gives details about books published by them" "External System"
        shippingSystem = softwareSystem "Shipping System" "The 3rd party Shipping Service handles the book delivery" "External System"
        
        # Relationship between People and Software Systems
        # <variable> -> <variable> <description> <protocol>
        publicUser -> bookstoreSystem "View book information"
        authorizedUser -> bookstoreSystem "Search book with more details"
        internalUser -> bookstoreSystem "Has all functions of Authorized User, manage books and purchases information"
        bookstoreSystem -> authSystem "Register new user, and authorize user access"
        bookstoreSystem -> shippingSystem "Create and track shipping orders"
        publisherSystem -> bookstoreSystem "Publish events for new book publication, and book information updates" {
            tags "Async Request"
        }

        # Relationship between Containers
        authorizedUser -> frontStoreApplication "Use"
        publicUser -> frontStoreApplication "Use"
        internalUser -> backOfficeApplication "Use"
        frontStoreApplication -> publicWebApi "Search books"
        frontStoreApplication -> searchWebApi "Search books or place orders"
        backOfficeApplication -> adminWebApi "Administrate books and purchases"
        publicUser -> publicWebApi "View book information" "JSON/HTTPS"
        publicWebApi -> bookstoreDatabase "Read/Write book data" "ODBC"
        authorizedUser -> searchWebApi "Search book with more details" "JSON/HTTPS"
        searchWebApi -> authSystem "Authorize user" "JSON/HTTPS"
        searchWebApi -> searchDatabase "Retrieve book search data" "ODBC"
        internalUser -> adminWebApi "Manage books and purchases information" "JSON/HTTPS"
        adminWebApi -> authSystem "Authorize user" "JSON/HTTPS"
        adminWebApi -> bookstoreDatabase "Read/Write book detail data" "ODBC"
        adminWebApi -> bookEventSystem "Publish book update events" {
            tags "Async Request"
        }
        bookEventSystem -> bookEventConsumer "Send events to"
        bookEventConsumer -> searchDatabase "Write book update data" "ODBC"
        publisherRecurrentUpdater -> adminWebApi "Makes API calls to" "JSON/HTTPS"

        # Relationship between Containers and External System
        publisherSystem -> publisherRecurrentUpdater "Publish events for new book publication, and book information updates" {
            tags "Async Request"
        }

        # Relationship between Components
        internalUser -> bookService "Administrate book details" "JSON/HTTPS"
        bookService -> authService "Uses"
        bookService -> bookEventPublisher "Uses"

        # Relationship between Components and Other Containers
        authService -> authSystem "Authorize user permissions" "JSON/HTTPS"
        bookService -> bookstoreDatabase "Read/Write data" "ODBC"
        bookEventPublisher -> bookEventSystem "Publish book update events"
    }

    views {
        # Level 1
        systemContext bookstoreSystem "SystemContext" {
            include *
            # default: tb,
            # support tb, bt, lr, rl
            autoLayout lr
        }
        # Level 2
        container bookstoreSystem "Containers" {
            include *
            autoLayout lr
        }
        # Level 3
        component adminWebApi "Components" {
            include *
            autoLayout lr
        }


        styles {
            # element <tag> {}
            element "Customer" {
                background #08427B
                color #ffffff
                fontSize 22
                shape Person
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Async Request" {
                dashed true
            }
            element "Database" {
                shape Cylinder
            }
        }

        theme default
    }

}