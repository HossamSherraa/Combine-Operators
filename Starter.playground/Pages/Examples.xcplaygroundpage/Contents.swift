import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Publisher") {
  // 1
  let myNotification = Notification.Name("MyNotification")
// 2
  let publisher = NotificationCenter.default
    .publisher(for: myNotification, object: nil)
    
    
    
    // 3
    let center = NotificationCenter.default
    // 4
    let observer = center.addObserver(
      forName: myNotification,
      object: nil,
      queue: nil) { notification in
        print("Notification received!")
    }
    // 5
    center.post(name: myNotification, object: nil)
    // 6
    center.removeObserver(observer)
}

example(of: "Subscriber") {
  let myNotification = Notification.Name("MyNotification")
  let publisher = NotificationCenter.default
    .publisher(for: myNotification, object: nil)
  let center = NotificationCenter.default
    
    let subscription = publisher
      .sink { _ in
        print("Notification received from a publisher!")
      }
    center.post(name: myNotification, object: nil)
   }


example(of: "Just") {
  // 1
  let just = Just("Hello world!")
// 2
  _ = just
    .sink(
      receiveCompletion: {
        print("Received completion", $0)
      },
      receiveValue: {
        print("Received value", $0)
    })
    
    _ = just
      .sink(
        receiveCompletion: {
          print("Received completion (another)", $0)
        },
        receiveValue: {
          print("Received value (another)", $0)
      })
}




example(of: "assign(to:on:)") {
  // 1
  class SomeObject {
    var value: String = "" {
didSet {
        print(value)
      }
} }
// 2
  let object = SomeObject()
  // 3
  let publisher = ["Hello", "world!"].publisher
// 4
  _ = publisher
    .assign(to: \.value, on: object)
}


class IntSubscriper<T , F: Error> : Subscriber {
  
    
  

    func receive(subscription: Subscription) {
        subscription.request(.max(5) )
    }
    
    func receive(_ input: T) -> Subscribers.Demand {
        print( #function , input)
        return .max(0)
    }
    
    func receive(completion: Subscribers.Completion<F>) {
        print(completion , "Completion")
    }
    
    
    typealias Input = T
    
    typealias Failure = F
    
    
}


//Create Custome Subscriber
["1" , "2"].publisher.subscribe(IntSubscriper<String , Never>())

//Hello Future

example(of: "Future") {
   
    func futureIncriment(number : Int , delay : Int )->Future<Int , Never>{
        Future.init { (promise) in
            print("Original")
            DispatchQueue.global().asyncAfter(wallDeadline: .now() + Double(delay)) {
                promise(.success(number + 1))
            }
        }
    }
    futureIncriment(number: 2, delay: 0)
        .sink { (v) in
            print(v)
        }
        .store(in: &subscriptions)
    
    
   
}






example(of: "CurrentSubject") {
    class Car {
      var kwhInBattery = CurrentValueSubject<Double, Never>(50.0)
      let kwhPerKilometer = 0.14

      func drive(kilometers: Double) {
        var kwhNeeded = kilometers * kwhPerKilometer

        assert(kwhNeeded <= kwhInBattery.value, "Can't make trip, not enough charge in battery")

        kwhInBattery.value -= kwhNeeded
      }
    }

    let car = Car()

    car.kwhInBattery.sink(receiveValue: { currentKwh in
      print("battery has \(currentKwh) remaining")
    })
    .store(in: &subscriptions)
    
    car.drive(kilometers: -200)
    
//    Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (_) in
//        car.kwhInBattery.value -= 20
//    }
   
}


example(of: "PassThrowSubject") {
    let passSubject = PassthroughSubject<String , Never>()
    passSubject.sink { (string) in
        print(string)
    }
    .store(in: &subscriptions)

    passSubject.send("RTR")
//    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
//        passSubject.send("RTTT")
//    }
    
    
    class PasssMe {
        static let passSubject = PassthroughSubject<String , Never>()
    }

    PasssMe.passSubject.sink { (va) in
        print(va)
    }

    PasssMe.passSubject.send("rtyyh")
}


example(of: "PassThrowSubject2") {
    let passSubject = PassthroughSubject<Int , Never>()
    
    class IntSubscriber : Subscriber {
        func receive(subscription: Subscription) {
            subscription.request(.max(1))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print(input)
            return .max(1)
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print(completion)
        }
        
       
        
        typealias Input = Int
        
        typealias Failure = Never
        
        
    }
    
    let subscriber = IntSubscriber()
    passSubject.subscribe(subscriber)
    
    passSubject.sink { (va) in
        print(va , "SINK")
    }
    
    passSubject.send(4)
    passSubject.send(44)
    passSubject.send(completion: .finished)
    passSubject.send(44)
}

example(of: "FlatMap") {
     struct WeatherStation {
        public let stationID: String
    }

    let weatherPublisher = PassthroughSubject<WeatherStation, URLError>()

      weatherPublisher.flatMap { station -> URLSession.DataTaskPublisher in
        let url = URL(string:"https://weatherapi.example.com/stations/\(station.stationID)/observations/latest")!
        return URLSession.shared.dataTaskPublisher(for: url)
    }
    .sink(
        receiveCompletion: { completion in
            // Handle publisher completion (normal or error).
        },
        receiveValue: {val in
            print(val)
            // Process the received data.
        }
     )

    weatherPublisher.send(WeatherStation(stationID: "KSFO")) // San Francisco, CA
    weatherPublisher.send(WeatherStation(stationID: "EGLC")) // London, UK
    weatherPublisher.send(WeatherStation(stationID: "ZBBB")) // Beijing, CN
}

example(of: "Prefix VS DROP") {
    let someNumbers = [1 , 2, 3, 4 ,5 ,6 ,7 ,8 ,9 ]
    someNumbers.publisher.drop(while: {$0 < 3})
        .sink { (val) in
            print(val)
        }
}


example(of: "Timer") {
   
    
    var timer = Timer.publish(every: 0.2, on: .main, in: .common)
        .autoconnect()
        .prefix(10)
        .count()
        .measureInterval(using: RunLoop.main)
        .sink { (ouy) in
           
        }
        .store(in: &subscriptions)
    
}


example(of: "Multicase") {
let multicase = [1,2,3,4,5,6,7,8,9,12]
        .publisher
        .multicast {
            PassthroughSubject<Int , Never>()
        }
        
    multicase.sink {
        print("first" + $0.description)
    }
    multicase.sink {
        print("second" + $0.description)
    }
    
    multicase.connect()
        
        
        
}


example(of: "Make Connectable") {
  let x =  [1,2,3,4,5,6,7,8,9]
    .publisher
    .map(\.self)

    
   
        
    x.sink { (val) in
        print(val)
    }.store(in: &subscriptions)
    

   
}

example(of: "Combine Latest") {
    let p1 = PassthroughSubject<Int , Never>()
    let p2 = PassthroughSubject<Int , Never>()
    
    p1.combineLatest(p2) // ZIP Uses Oldest , CombineLatest Uses Newest
        .sink { (val) in
            print(val)
        }
    
    p1.send(1)
    p1.send(3)
    p2.send(44)
    
    
}

example(of: "Combine Latest") {
    let p1 = PassthroughSubject<Int , Never>()
    let p2 = PassthroughSubject<Int , Never>()
    
    p1.zip(p2) // ZIP Uses Oldest , CombineLatest Uses Newest
        .sink { (val) in
            print(val)
        }
    
    p1.send(1)
    p1.send(3)
    p2.send(44)
    
    
}

example(of: "FlatMap") {
    [1,2,3,4,5,6,7]
        .publisher
        .flatMap(maxPublishers:.max(1)) { (number) in
           PassthroughSubject<Int , Never>()
        }
        .sink { (val) in
            
        }
}


example(of: "Share") {
    
    let pub = (1...3).publisher
        
        .map( { _ in return Int.random(in: 0...100) } )
        .delay(for: 0.5, scheduler: RunLoop.main)
        .share()
       

   pub
        .sink { print ("Stream 1 received: \($0)")}
    .store(in: &subscriptions)
    pub
        .sink { print ("Stream 2 received: \($0)")}
        .store(in: &subscriptions)
    
    
}
