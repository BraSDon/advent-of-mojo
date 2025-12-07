from pathlib import Path
import os

fn read(day: Int, example: Bool = False) raises -> List[String]:
    var day_str = String(day)
    if day < 10:
        day_str = "0" + day_str
    
    var dir = "examples" if example else "inputs"
    var path = Path("../" + dir + "/day" + day_str + ".txt")
    var content = List[String]()
    with open(path, "r") as f:
        var lines = f.read().split("\n")
        for line in lines:
            content.append(String(line))
    return content^