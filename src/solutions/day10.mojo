from testing import assert_equal, assert_true
from read import read
from bit import log2_floor

fn main() raises:
    var input = read(10)
    var example = read(10, True)

    assert_equal(part_one(example.value()), 7)
    assert_equal(part_one(input.value()), 441)

    # assert_equal(part_two(example.value()), 6)
    # assert_equal(part_two(input.value()), 5782)

alias Bitvec = UInt32
struct EquationSystem(Stringable):
    var A: List[Bitvec] # lights x buttons + 1 (last column is b)
    var lights: UInt32
    var buttons: UInt32

    fn __init__(out self, indicator_lights: IndicatorLights, lights: Int, buttons: Buttons) raises:
        # lights = position of highest set bit + 1
        # buttons = len(buttons)
        # A is lights x (buttons + 1), we add b as last column
        # b is indicator_lights
        self.lights = UInt32(lights)
        self.buttons = len(buttons)
        assert_true(self.buttons < 32, "Too many buttons to fit in Bitvec")
        self.A = List[Bitvec](length=lights, fill=0)
        for i in range(lights):
            var row: UInt32 = 0
            for j, button in enumerate(buttons):
                # Get i-th bit from the left, so self.lights - 1 - i
                var bit = button >> (self.lights - 1 - i) & 1 # mask to only get the first bit
                row |= bit << (self.buttons - j)
            var b_bit = indicator_lights >> (self.lights - 1 - i) & 1
            row |= b_bit
            self.A[i] = row


    fn perform_gaussian_elimination(self, mut mat: List[Bitvec]) -> List[Int]:
        """Transforms matrix to RREF and returns pivot row index for each column."""
        var pivot_row = 0
        var pivot_map = List[Int](length=Int(self.buttons), fill=-1)

        for j in range(self.buttons):
            var col_bit = self.buttons - j
            var sel = -1
            for i in range(pivot_row, self.lights):
                if (mat[i] >> col_bit) & 1:
                    sel = i
                    break
            if sel != -1:
                # Swap rows
                var temp = mat[sel]
                mat[sel] = mat[pivot_row]
                mat[pivot_row] = temp
                # Eliminate other rows
                for i in range(self.lights):
                    if i != pivot_row and ((mat[i] >> col_bit) & 1):
                        mat[i] ^= mat[pivot_row]
                pivot_map[j] = pivot_row
                pivot_row += 1
        return pivot_map^

    fn solve(self) -> Int:
        var mat = self.A.copy()
        var pivot_map = self.perform_gaussian_elimination(mat)

        # Identify free variables
        var free_vars = List[Int]()
        for j in range(self.buttons):
            if pivot_map[j] == -1:
                free_vars.append(Int(j))
        return self.find_min_presses(mat, pivot_map, free_vars)

    fn find_min_presses(self, mat: List[Bitvec], pivot_map: List[Int], free_vars: List[Int]) -> Int:
        var min_presses = 1000000 
        var num_free = len(free_vars)

        # Try all 2^num_free combinations of free variables
        for i in range(1 << num_free):
            var current_solution_weight = 0
            var solution_vector = Bitvec(0)
            # 1. Set values for free variables based on current 'i'
            for idx in range(num_free):
                if (i >> idx) & 1:
                    current_solution_weight += 1
                    solution_vector |= (Bitvec(1) << (self.buttons - free_vars[idx]))
            # 2. Calculate values for pivot variables
            for j in range(self.buttons):
                var row_idx = pivot_map[j]
                if row_idx != -1:
                    # Variable value = b_row XOR (sum of free_var_bits in that row)
                    var val = mat[row_idx] & 1
                    for f_idx in range(num_free):
                        var f_col = self.buttons - free_vars[f_idx]
                        if (mat[row_idx] >> f_col) & 1:
                            val ^= ((i >> f_idx) & 1)
                    if val == 1:
                        current_solution_weight += 1
            if current_solution_weight < min_presses:
                min_presses = current_solution_weight
        return min_presses


    fn __str__(self) -> String:
        # Print 1s and 0s, separate last column with |
        var result = ""
        for i in range(self.lights):
            result += int_to_bin_str(self.A[i], length=Int(self.buttons) + 1, separate_last_col=True) + "\n"
        return result

alias IndicatorLights = Bitvec
alias Buttons = List[Bitvec]

fn parse_indicator_lights(repr: String) -> Tuple[IndicatorLights, Int]:
    # . = 0, # = 1
    # remove left and right edge ("[" and "]")
    # Example: "[#..#.#]" -> "100101"
    var bits = repr[1:-1]
    var result: IndicatorLights = 0
    for i in range(len(bits)):
        var pos = len(bits) - 1 - i
        if bits[pos] == "#":
            result |= (1 << i)
    return (result, len(bits))

fn parse_buttons(repr: List[String], button_count: Int, lights: Int) raises -> Buttons:
    var buttons = List[Bitvec](capacity=button_count)
    for i in range(button_count):
        # Example with 8 lights: (0, 3, 4) -> "10011000"
        var idx = repr[i][1:-1]
        var result: Bitvec = 0
        var positions = idx.split(",")
        for pos_str in positions:
            var pos = atol(pos_str)
            result |= (1 << (lights - 1 - pos))
        buttons.append(result)
    return buttons^

fn parse_input(input: List[String]) raises -> List[Tuple[IndicatorLights, Int, Buttons]]:
    var output = List[Tuple[IndicatorLights, Int, Buttons]](capacity=len(input))
    for line in input:
        var elements = line.split(" ")
        var p = parse_indicator_lights(String(elements[0]))
        var indicator_lights = p[0]
        var rest = [String(e) for e in elements[1:-1]]
        var buttons = parse_buttons(rest, button_count=len(rest), lights=p[1])
        output.append((indicator_lights, p[1], buttons^))
    return output^

fn int_to_bin_str(value: Bitvec, length: Int, separate_last_col: Bool = False) -> String:
    var result = ""
    for i in range(length):
        var bit = (value >> (length - 1 - i)) & 1
        if separate_last_col and i == length - 1:
            result += " | "
        result += "1" if bit == 1 else "0"
    return result

fn debug_print(parsed: List[Tuple[IndicatorLights, Int, Buttons]]) raises:
    for (indicator_lights, lights, buttons) in parsed:
        print("Indicator Lights: {}".format(int_to_bin_str(indicator_lights, length=lights)))
        for i in range(len(buttons)):
            print(" Button {}: {}".format(i, int_to_bin_str(buttons[i], length=lights)))
        break

fn part_one(input: List[String]) raises -> Int:
    var parsed = parse_input(input)
    var count = 0
    for (indicator_lights, lights, buttons) in parsed:
        var system = EquationSystem(indicator_lights, lights, buttons)
        count += system.solve()
    return count

fn part_two(input: List[String]) raises -> Int:
    return 0
