from testing import assert_equal, assert_true
from read import read

def main():
    var input = read(1)
    var example = read(1, True)

    assert_equal(part_one(example), 3)
    assert_equal(part_one(input), 962)

    assert_equal(part_two(example), 6)
    assert_equal(part_two(input), 5782)

def parse_input(input: List[String]) -> List[Int]:
    var parsed = List[Int]()
    for line in input:
        var direction = -1 if line[0] == "L" else 1
        var steps = Int(line[1:])
        parsed.append(direction * steps)
    return parsed^

fn part_one(input: List[String]) -> Int:
    var parsed = List[Int]()
    try:
        parsed = parse_input(input)
    except _:
        print("Invalid input")
    var zeros = 0
    var current = 50
    for step in parsed:
        current = (current + step) % 100
        if current == 0:
            zeros += 1
    return zeros

fn part_two(input: List[String]) -> Int:
    var parsed = List[Int]()
    try:
        parsed = parse_input(input)
    except _:
        print("Invalid input")
    var zeros = 0
    var current = 50
    for step in parsed:
        # Ensure that landing on 0 is counted as crossing the "boundary" when moving left
        var offset = -1 if step < 0 else 0
        var start_idx = (current + offset) // 100
        var end_idx = (current + step + offset) // 100
        zeros += abs(end_idx - start_idx)
        current = (current + step) % 100
    return zeros
