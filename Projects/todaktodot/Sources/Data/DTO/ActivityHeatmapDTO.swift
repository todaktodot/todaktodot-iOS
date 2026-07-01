//
//  ActivityHeatmapDTO.swift
//  todaktodot
//
//  Created by 임대진 on 7/1/26.
//

import Foundation

struct ActivityHeatmapDTO: Decodable {
    let startDate: String
    let endDate: String
    let days: [ActivityDay]
}

extension ActivityHeatmapDTO {
    func toHeatmap() -> ActivityHeatmap {
        return ActivityHeatmap(days: days)
    }
}

