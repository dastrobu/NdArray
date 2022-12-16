//
// Created by Daniel Strobusch on 14.12.22.
//

import Foundation
import NdArray

func sendRequest(_ json: Any,
                 method: String = "POST",
                 contentType: String = "application/json",
                 url: URL = URL(string: "http://localhost:9898/plots")!) {
    let semaphore = DispatchSemaphore(value: 0)
    let jsonData = try? JSONSerialization.data(withJSONObject: json)
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
    request.setValue(contentType, forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        print("status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        semaphore.signal()
    }
    task.resume()
    semaphore.wait()
}


func plot(_ y: [Any]) {
    let x = NdArray<Int>.range(to: y.count)
    plot(x: x.dataArray, y: y)
}

func plot(x: [Any], y: [Any]) {
    sendRequest([
        "data": [
            [
                "x": x,
                "y": y,
                "mode": "lines+markers",
                "type": "scatter",
            ]
        ]
    ])
}

func heatmap<T: FloatingPoint>(_ m: Matrix<T>) {
    let z = Array(m).map({ Array($0) })
    var annotations: [Any] = []
    for i in 0..<m.shape[0] {
        for j in 0..<m.shape[1] {
            annotations.append([
                "x": j,
                "y": i,
                "text": m[i, j],
                "showarrow": false
            ])

        }
    }
    let json: Any = [
        "data": [
            [
                "z": z,
                "type": "heatmap"
            ],
        ],
        "layout": [
            "xaxis": [
                "dtick": 1,
                "tick0": 1,
            ],
            "yaxis": [
                "autorange": "reversed",
                "dtick": 1,
                "tick0": 1,
            ],
            "annotations": annotations
        ]
    ]
    sendRequest(json)
}

func plot<T: FloatingPoint>(_ a: NdArray<T>) {
    switch a.ndim {
    case 1:
        plot(a.dataArray)
    case 2:
        heatmap(Matrix<T>(a))
    default:
        print("bad ndim: \(a.ndim)")
    }
}
