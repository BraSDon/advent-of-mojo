from testing import assert_equal, assert_true
from read import read

fn main() raises:
    var input = read(3)
    var example = read(3, True)

    var parsed_input = parse_input(input.value())
    var parsed_example = parse_input(example.value())

    assert_equal(part_one(parsed_example), 357)
    assert_equal(part_one(parsed_input), 17332)

    assert_equal(part_two(parsed_example), 3121910778619)
    assert_equal(part_two(parsed_input), 172516781546707)

alias Bank = List[Int]

fn parse_input(input: List[String]) raises -> List[Bank]:
    var banks = List[Bank]()
    for line in input:
        var bank = List[Int]()
        for char in line:
            bank.append(Int(char))
        banks.append(bank^)
    return banks^

fn build_map(bank: Bank) raises -> Dict[Int, List[Int]]:
    # Build map of digit -> first occurrence index
    var map = Dict[Int, List[Int]]()
    for i, x in enumerate(bank):
        var found = map.find(x)
        if found:
            map[x].append(i)
        else:
            map[x] = [i]
    return map^

fn find_best_digit(map: Dict[Int, List[Int]], min_index: Int, max_index: Int) -> Tuple[Int, Int]:
    """Find largest digit (9->1) with any occurrence in [min_index, max_index)."""
    for digit in range(9, 0, -1):
        var positions = map.find(digit)
        if positions:
            for pos in positions.value():
                if min_index <= pos < max_index:
                    return (digit, pos)
    return (0, 0)

fn select_digits(map: Dict[Int, List[Int]], count: Int, bank_len: Int) -> List[Int]:
    var values = List[Tuple[Int, Int]](length=count, fill=(0, 0))
    values[0] = find_best_digit(map, 0, bank_len  - (count - 1))
    for i in range(1, count):
        var min_index = values[i - 1][1] + 1
        var max_index = bank_len - (count - 1 - i)
        values[i] = find_best_digit(map, min_index, max_index)
    var result = List[Int]()
    for v in values:
        result.append(v[0])
    return result^

fn digits_to_number(digits: List[Int]) raises -> Int:
    var s = String()
    for d in digits:
        s += String(d)
    return atol(s)

fn solve(input: List[Bank], count: Int) raises -> Int:
    var sum = 0
    for bank in input:
        var map = build_map(bank)
        sum += digits_to_number(select_digits(map, count, len(bank)))
    return sum

fn part_one(input: List[Bank]) raises -> Int:
    return solve(input, 2)

fn part_two(input: List[Bank]) raises -> Int:
    return solve(input, 12)

