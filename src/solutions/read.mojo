from pathlib import Path
import os

fn read(day: Int, example: Bool = False) -> Optional[List[String]]:
    var day_str = String(day)
    if day < 10:
        day_str = "0" + day_str
    
    var dir = "examples" if example else "inputs"
    var path = Path("../" + dir + "/day" + day_str + ".txt")
    var content = List[String]()
    try:
        with open(path, "r") as f:
            var lines = f.read().split("\n")
            for line in lines:
                content.append(String(line))
    except e:
        print("Error reading file:", e)
        return Optional[List[String]](None)
    return Optional(content^)
