from testing import assert_equal, assert_true
from read import read
from collections import Set

fn main() raises:
    var input = read(2)
    var example = read(2, True)

    assert_equal(part_one(example.value()), 1227775554)
    assert_equal(part_one(input.value()), 32976912643)

    assert_equal(part_two(example.value()), 4174379265)
    assert_equal(part_two(input.value()), 54446379122)

@fieldwise_init
struct Range(Copyable, Movable, ImplicitlyCopyable, Stringable):
    var start: Int
    var end: Int # Inclusive

    fn __str__(self) -> String:
        return "Range(" + String(self.start) + ", " + String(self.end) + ")"

    fn split(self) -> List[Range]:
        # Example: 1 - 1002
        # 1 - 9
        # 10 - 99
        # 100 - 999
        # 1000 - 1002
        var ranges = List[Range]()
        var start = self.start
        var end = self.end

        while not same_length(start, end):
            start_string = String(start)
            try:
                end = Int("1" + "0" * len(start_string)) - 1
            except:
                return []
            ranges.append(Range(start, end))
            start = end + 1
            end = self.end

        ranges.append(Range(start, self.end))
        return ranges^

    fn even(self) -> Bool:
        return len(String(self.start)) % 2 == 0

    fn contains(self, x: Int) -> Bool:
        return self.start <= x <= self.end

fn same_length(x: Int, y: Int) -> Bool:
    return len(String(x)) == len(String(y))

fn parse_input(input: List[String]) raises -> List[Range]:
    var parsed = List[Range]()
    var line = input[0]

    var parts = line.split(",")
    for part in parts:
        var bounds = part.split("-")
        var start = Int(bounds[0])
        var end = Int(bounds[1])
        parsed.append(Range(start, end))

    return parsed^

fn split_ranges(input: List[Range]) -> List[Range]:
    var ranges = List[Range]()
    for r in input:
        ranges.extend(r.split())
    return ranges^

fn sum_set(nums: Set[Int]) -> Int:
    var sum = 0
    for n in nums:
        sum += n
    return sum

fn part_one(input: List[String]) raises -> Int:
    # 1. Turn into sub-ranges, that all satisfy the invariant
    # 2. Get rid of ranges where digits(start) % 2 != 0
    # 3. For each range, take first half of digits (s), check if (ss) is in range
    #    If yes, then take (s+1) and check if (s+1)(s+1) is in range etc...
    var parsed = parse_input(input)
    var ranges = split_ranges(parsed)
    for r in ranges:
        assert_true(same_length(r.start, r.end))

    var filtered = [r for r in ranges if r.even()]

    var nums = Set[Int]()
    for r in filtered:
        nums |= invalid_ids(2, r)

    return sum_set(nums)

fn part_two(input: List[String]) raises -> Int:
    var parsed = parse_input(input)
    var ranges = split_ranges(parsed)

    var nums = Set[Int]()
    for r in ranges:
        for ratio in range(2, len(String(r.start)) + 1):
            if len(String(r.start)) % ratio != 0:
                continue
            nums |= invalid_ids(ratio, r)

    return sum_set(nums)

fn invalid_ids(ratio: Int, r: Range) raises -> Set[Int]:
    var nums = Set[Int]()
    var str = String(r.start)
    var sequence = str[:len(str) // ratio]
    var seq_len = len(sequence)
    var x = Int(sequence)
    while len(sequence) <= seq_len:
      var s = sequence * ratio
      var potential_invalid = Int(s)
      if potential_invalid > r.end:
          break
      if potential_invalid >= r.start:
          nums.add(potential_invalid)
      sequence = String(Int(sequence) + 1)

    return nums^
