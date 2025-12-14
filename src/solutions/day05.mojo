from testing import assert_equal
from read import read
from collections.interval import Interval

fn main() raises:
    var input = read(5)
    var example = read(5, True)

    assert_equal(part_one(example.value()), 3)
    assert_equal(part_one(input.value()), 726)

    # assert_equal(part_two(example.value()), 14)
    # assert_equal(part_two(input.value()), 9144)

fn parse(input: List[String]) raises -> Tuple[List[Interval[Int]], List[Int]]:
    var split_index = 0
    var ranges = List[Interval[Int]]()
    for i, line in enumerate(input):
        var parts = line.strip().split("-")
        if len(parts) != 2:
            split_index = i
            break
        ranges.append(Interval[Int](atol(parts[0]), atol(parts[1]) + 1))

    var avail = List[Int]()
    for line in input[split_index + 1:]:
        avail.append(atol(line))

    return (ranges^, avail^)

fn is_fresh(value: Int, ranges: List[Interval[Int]]) -> Bool:
    for r in ranges:
        if value in r:
            return True
    return False

fn part_one(input: List[String]) raises -> Int:
    var parsed = parse(input)
    var ranges = parsed[0].copy()
    var avail = parsed[1].copy()

    var count = 0
    for value in avail:
        if is_fresh(value, ranges):
            count += 1

    return count

fn part_two(input: List[String]) raises -> Int:
    return 0
