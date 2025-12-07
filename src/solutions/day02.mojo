from testing import assert_equal, assert_true
from read import read

fn main() raises:
    var input = read(2)
    var example = read(2, True)

    var parsed_input = parse_input(input.value())
    var parsed_example = parse_input(example.value())

    assert_equal(part_one(parsed_example), 1227775554)
    assert_equal(part_one(parsed_input), 32976912643)

    # assert_equal(part_two(parsed_example), 6)
    # assert_equal(part_two(parsed_input), 5782)

fn same_length(x: Int, y: Int) -> Bool:
    return len(String(x)) == len(String(y))

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


fn part_one(input: List[Range]) raises -> Int:
    # 1. Turn into sub-ranges, that all satisfy the invariant
    # 2. Get rid of ranges where digits(start) % 2 != 0
    # 3. For each range, take first half of digits (s), check if (ss) is in range
    #    If yes, then take (s+1) and check if (s+1)(s+1) is in range etc...

    # 1.
    var ranges = List[Range]()
    for r in input:
        ranges.extend(r.split())
    for r in ranges:
        assert_true(same_length(r.start, r.end))

    # 2.
    var filtered = [r for r in ranges if r.even()]

    for r in filtered:
        print(r.__str__())

    # 3.
    var sum = 0
    for r in filtered:
      var str = String(r.start)
      var half = str[:len(str) // 2]
      var x = Int(half)
      while True:
          var potential_invalid = Int(half + half)
          if potential_invalid > r.end:
              break
          if potential_invalid >= r.start:
              sum += potential_invalid
          half = String(Int(half) + 1)

    return sum

fn part_two(input: List[Range]) -> Int:
    return 0
