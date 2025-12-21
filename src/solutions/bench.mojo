from benchmark import run, Unit, Report
from benchmark.compiler import keep
from read import read
import day01
import day02
import day03
import day04
import day05
import day06
import day07
import day08

fn main() raises:
    run_day[day01.part_one, day01.part_two](1)
    run_day[day02.part_one, day02.part_two](2)
    run_day[day03.part_one, day03.part_two](3)
    run_day[day04.part_one, day04.part_two](4)
    run_day[day05.part_one, day05.part_two](5)
    run_day[day06.part_one, day06.part_two](6)
    run_day[day07.part_one, day07.part_two](7)
    run_day[day08.part_one, day08.part_two](8)

fn run_day[
    part1_fn: fn(List[String]) raises -> Int,
    part2_fn: fn(List[String]) raises -> Int
](day: Int) raises:
    print("Day {}:".format(day))
    var i = read(day)
    var input = i.take()
    bench_part[part1_fn](input, 1)
    bench_part[part2_fn](input, 2)
    print("") # Newline

fn bench_part[
    func: fn(List[String]) raises -> Int,
](input: List[String], part: Int) raises:

    @parameter
    fn wrapper() raises:
        _ = keep(func(input))

    var unit = Unit.ms
    var report = run[wrapper](max_iters=50)
    var mean = report.mean(Unit.ms)
    print("  Part {}: {} {}".format(part, mean.__round__(4), unit))
