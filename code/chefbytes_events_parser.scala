import scala.io.Source

abstract class Event(val param1: Option[Int], val param2: Option[Int]) {
  def displayInfo(): Unit
}

// Define subclasses for each event type
case class COL(override val param1: Option[Int]) extends Event(param1, None) {
  def displayInfo(): Unit = println(s"COL Event: Param1 = ${param1.map(_ / 100.0)}")
}

case class AGR(override val param1: Option[Int], override val param2: Option[Int]) extends Event(param1, param2) {
  def displayInfo(): Unit = println(s"AGR Event: Param1 = ${param1.map(_ / 100.0)}, Param2 = $param2")
}

case class DRC(override val param1: Option[Int], override val param2: Option[Int]) extends Event(param1, param2) {
  def displayInfo(): Unit = println(s"DRC Event: Param1 = ${param1.map(_ / 100.0)}, Param2 = $param2")
}

case class ADV(override val param1: Option[Int], override val param2: Option[Int]) extends Event(param1, param2) {
  def displayInfo(): Unit = println(s"ADV Event: Param1 = ${param1.map(_ / 100.0)}, Param2 = $param2")
}

case class ORD(override val param1: Option[Int]) extends Event(param1, None) {
  def displayInfo(): Unit = println(s"ORD Event: Param1 = ${param1.map(_ / 100.0)}")
}

case class PIC(override val param1: Option[Int]) extends Event(param1, None) {
  def displayInfo(): Unit = println(s"PIC Event: Param1 = ${param1.map(_ / 100.0)}")
}

case class DEL(override val param2: Option[Int]) extends Event(None, param2) {
  def displayInfo(): Unit = println(s"DEL Event: Param2 = $param2")
}

case class DWT(override val param1: Option[Int], override val param2: Option[Int]) extends Event(param1, param2) {
  def displayInfo(): Unit = println(s"DWT Event: Param1 = ${param1.map(_ / 100.0)}, Param2 = $param2")
}

case class RWT(override val param1: Option[Int], override val param2: Option[Int]) extends Event(param1, param2) {
  def displayInfo(): Unit = println(s"RWT Event: Param1 = ${param1.map(_ / 100.0)}, Param2 = $param2")
}

object EventProcessor {
  def parseIntWithFixedPrecision(value: String): Option[Int] = {
    if (value.isEmpty) None else Some((value.toDouble * 100).toInt)
  }

  def parseInt(value: String): Option[Int] = {
    if (value.isEmpty) None else Some(value.toInt)
  }

  def parseEvent(eventType: String, param1: String, param2: String): Event = {
    val p1 = parseIntWithFixedPrecision(param1)
    val p2 = parseInt(param2)

    eventType match {
      case "COL" => COL(p1)
      case "AGR" => AGR(p1, p2)
      case "DRC" => DRC(p1, p2)
      case "ADV" => ADV(p1, p2)
      case "ORD" => ORD(p1)
      case "PIC" => PIC(p1)
      case "DEL" => DEL(p2)
      case "DWT" => DWT(p1, p2)
      case "RWT" => RWT(p1, p2)
      case _ => throw new IllegalArgumentException(s"Unknown event type: $eventType")
    }
  }

  def main(args: Array[String]): Unit = {
    val filePath = "../examples/chefbytes_events/events.csv"

    val lines = Source.fromFile(filePath).getLines().drop(1) // Skip header

    val events = lines.map { line =>
      val Array(eventType, param1, param2) = line.split(",", -1)
      parseEvent(eventType, param1, param2)
    }.toList

    events.foreach(_.displayInfo())
  }
}
