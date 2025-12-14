from testing import assert_equal
from read import read
from collections.interval import Interval

fn main() raises:
    var input = read(5)
    var example = read(5, True)

    assert_equal(part_one(example.value()), 3)
    assert_equal(part_one(input.value()), 726)

    assert_equal(part_two(example.value()), 14)
    assert_equal(part_two(input.value()), 354226555270043)

struct IntervalWrapper(Copyable, Movable, Comparable):
    var interval: Interval[Int]

    @implicit
    fn __init__(out self, interval: Interval[Int]):
        self.interval = interval

    fn __lt__(self, other: IntervalWrapper) -> Bool:
        return self.interval < other.interval

    fn __eq__(self, other: IntervalWrapper) -> Bool:
        return self.interval == other.interval

fn parse_ranges(input: List[String]) raises -> List[Interval[Int]]:
    var ranges = List[Interval[Int]]()
    for line in input:
        var parts = line.strip().split("-")
        # Stop as soon as we hit the split line
        if len(parts) != 2:
            break
        ranges.append(Interval[Int](atol(parts[0]), atol(parts[1]) + 1))
    return ranges^

fn parse_avail(input: List[String]) raises -> List[Int]:
    var split_index = 0
    for i in range(len(input)):
        var parts = input[i].strip().split("-")
        if len(parts) != 2:
            split_index = i
            break
    var avail = List[Int]()
    for i in range(split_index + 1, len(input)):
        avail.append(atol(input[i]))
    return avail^

fn is_fresh(value: Int, ranges: List[Interval[Int]]) -> Bool:
    for r in ranges:
        if value in r:
            return True
    return False

fn part_one(input: List[String]) raises -> Int:
    var ranges = parse_ranges(input)
    var avail = parse_avail(input)

    var count = 0
    for value in avail:
        if is_fresh(value, ranges):
            count += 1

    return count

fn part_two(input: List[String]) raises -> Int:
    var ranges = parse_ranges(input)

    # Workaround for sorting intervals
    var intervals = [IntervalWrapper(r) for r in ranges]
    sort(intervals)
    var itvs = [interval.interval for interval in intervals]

    var merged = List[Interval[Int]]()
    var current = itvs[0]

    for i in range(1, len(itvs)):
        var next = itvs[i]
        if current.overlaps(next):
            current = Interval(current.start, max(current.end, next.end))
        else: 
            merged.append(current)
            current = next

    merged.append(current)

    var count = 0
    for r in merged:
        count += len(r)

    return count
