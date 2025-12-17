from testing import assert_equal
from read import read

fn main() raises:
    var input = read(6)
    var example = read(6, True)

    assert_equal(part_one(example.value()), 4277556)
    assert_equal(part_one(input.value()), 4719804927602)

    # assert_equal(part_two(example.value()), 14)
    # assert_equal(part_two(input.value()), 354226555270043)

@fieldwise_init
struct Problem(Copyable, Movable):
    var nums: List[Int]
    var is_mul: Bool

    fn fold(self) -> Int:
        var result = self.nums[0]
        for i in range(1, len(self.nums)):
            if self.is_mul:
                result = result * self.nums[i]
            else:
                result = result + self.nums[i]
        return result

fn parse(input: List[String]) raises -> List[Problem]:
    var problems = List[Problem]()
    var nums = List[List[Int]]()
    var ops = input[len(input) - 1].split()
    for i, line in enumerate(input):
        if i == len(input) - 1:
            break
        nums.append([atol(i) for i in line.split()])

    for i in range(len(ops)):
        var elements = [n[i] for n in nums]
        problems.append(Problem(elements^, ops[i] == "*"))

    return problems^


fn part_one(input: List[String]) raises -> Int:
    var parsed = parse(input)
    var nums = [p.fold() for p in parsed]
    var count = 0
    for n in nums:
        count += n
    return count


fn part_two(input: List[String]) raises -> Int:
    return 0
