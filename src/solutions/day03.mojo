from testing import assert_equal, assert_true
from read import read

fn main() raises:
    var input = read(3)
    var example = read(3, True)

    var parsed_input = parse_input(input.value())
    var parsed_example = parse_input(example.value())

    assert_equal(part_one(parsed_example), 357)
    assert_equal(part_one(parsed_input), 962)

    # assert_equal(part_two(parsed_example), 6)
    # assert_equal(part_two(parsed_input), 5782)

alias Bank = List[Int]

fn parse_input(input: List[String]) raises -> List[Bank]:
    var banks = List[Bank]()
    for line in input:
        var bank = List[Int]()
        for char in line:
            bank.append(Int(char))
        banks.append(bank^)
    return banks^

fn find_best_digit(map: Dict[Int, List[Int]], min_index: Int, max_index: Int) -> Tuple[Int, Int]:
    """Find largest digit (9->1) with any occurrence in [min_index, max_index)."""
    for digit in range(9, 0, -1):
        var positions = map.find(digit)
        if positions:
            for pos in positions.value():
                if min_index <= pos < max_index:
                    return (digit, pos)
    return (0, 0)

fn part_one(input: List[Bank]) raises -> Int:
    var sum = 0
    for bank in input:
        # Build map of digit -> first occurrence index
        var map = Dict[Int, List[Int]]()
        for i, x in enumerate(bank):
            if not map.find(x):
                map[x] = [i]
            else:
                map[x].append(i)

        # First digit can't be at last position (need room for second digit)
        var first = find_best_digit(map, 0, len(bank) - 1)
        # Second digit must come after first
        var second = find_best_digit(map, first[1] + 1, len(bank))

        sum += first[0] * 10 + second[0]
    return sum

