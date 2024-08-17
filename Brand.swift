import Foundation

enum Brand: String, CaseIterable {
    case _765AS = "765AS"
    case CinderellaGirls
    case MillionLive
    case SideM
    case ShinyColors
    case Gakuen
    case valiv = "va-liv"
}
extension Brand: Identifiable { var id: Self { self } }
