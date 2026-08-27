#include "VSimTop.h"
#include "VSimTop___024root.h"
#include "svdpi.h"
#include "verilated.h"

#if VM_TRACE
#include "verilated_fst_c.h"
#endif

#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iterator>
#include <memory>
#include <string>
#include <vector>

namespace {
std::vector<std::uint8_t> image;
std::uint64_t current_cycle = 0;
std::uint64_t commit_count = 0;
bool commits_enabled = false;
bool trap_seen = false;
std::int32_t trap_code = 0;

std::string plusarg(const char* prefix, int argc, char** argv) {
  const std::string key(prefix);
  for (int i = 1; i < argc; ++i) {
    const std::string arg(argv[i]);
    if (arg.rfind(key, 0) == 0) {
      return arg.substr(key.size());
    }
  }
  return {};
}

std::uint64_t plusarg_u64(const char* prefix, std::uint64_t default_value,
                          int argc, char** argv) {
  const std::string value = plusarg(prefix, argc, argv);
  if (value.empty()) {
    return default_value;
  }
  char* end = nullptr;
  const auto parsed = std::strtoull(value.c_str(), &end, 0);
  if (end == value.c_str() || *end != '\0') {
#ifdef YSYXSOC_SIM_OUTPUT
    std::cerr << "Invalid integer argument: " << prefix << value << '\n';
#endif
    std::exit(2);
  }
  return parsed;
}

bool load_image(const std::string& path) {
  std::ifstream input(path, std::ios::binary);
  if (!input) {
    return false;
  }
  image.assign(std::istreambuf_iterator<char>(input),
               std::istreambuf_iterator<char>());
  return true;
}

std::uint32_t read_word(std::uint32_t offset) {
  std::uint32_t value = 0;
  for (std::uint32_t byte = 0; byte < 4; ++byte) {
    const auto index = static_cast<std::size_t>(offset) + byte;
    if (index < image.size()) {
      value |= static_cast<std::uint32_t>(image[index]) << (byte * 8);
    }
  }
  return value;
}

#define CORE_PC_CASE(index)                                                   \
  case index:                                                                 \
    return root                                                               \
        ->SimTop__DOT__asic__DOT__soc__DOT__cpu__DOT__core##index##__DOT__ifu__DOT__PC

std::uint32_t core_pc(const VSimTop___024root* root, std::uint8_t core) {
  switch (core) {
    CORE_PC_CASE(0); CORE_PC_CASE(1); CORE_PC_CASE(2); CORE_PC_CASE(3);
    CORE_PC_CASE(4); CORE_PC_CASE(5); CORE_PC_CASE(6); CORE_PC_CASE(7);
    CORE_PC_CASE(8); CORE_PC_CASE(9); CORE_PC_CASE(10); CORE_PC_CASE(11);
    CORE_PC_CASE(12); CORE_PC_CASE(13); CORE_PC_CASE(14); CORE_PC_CASE(15);
    CORE_PC_CASE(16); CORE_PC_CASE(17); CORE_PC_CASE(18); CORE_PC_CASE(19);
    CORE_PC_CASE(20); CORE_PC_CASE(21); CORE_PC_CASE(22); CORE_PC_CASE(23);
    CORE_PC_CASE(24); CORE_PC_CASE(25); CORE_PC_CASE(26); CORE_PC_CASE(27);
    CORE_PC_CASE(28); CORE_PC_CASE(29); CORE_PC_CASE(30); CORE_PC_CASE(31);
    default: return 0;
  }
}

#undef CORE_PC_CASE

#define CORE_FETCH_CASE(index)                                                \
  case index:                                                                 \
    return root                                                               \
        ->SimTop__DOT__asic__DOT__soc__DOT__cpu__DOT___cpu_##index##_io_ifu_reqValid

bool core_fetch_request(const VSimTop___024root* root, std::uint8_t core) {
  if (core == 0) {
    return root
        ->SimTop__DOT__asic__DOT__soc__DOT__cpu__DOT___cpu_io_ifu_reqValid;
  }
  switch (core) {
    CORE_FETCH_CASE(1); CORE_FETCH_CASE(2); CORE_FETCH_CASE(3);
    CORE_FETCH_CASE(4); CORE_FETCH_CASE(5); CORE_FETCH_CASE(6);
    CORE_FETCH_CASE(7); CORE_FETCH_CASE(8); CORE_FETCH_CASE(9);
    CORE_FETCH_CASE(10); CORE_FETCH_CASE(11); CORE_FETCH_CASE(12);
    CORE_FETCH_CASE(13); CORE_FETCH_CASE(14); CORE_FETCH_CASE(15);
    CORE_FETCH_CASE(16); CORE_FETCH_CASE(17); CORE_FETCH_CASE(18);
    CORE_FETCH_CASE(19); CORE_FETCH_CASE(20); CORE_FETCH_CASE(21);
    CORE_FETCH_CASE(22); CORE_FETCH_CASE(23); CORE_FETCH_CASE(24);
    CORE_FETCH_CASE(25); CORE_FETCH_CASE(26); CORE_FETCH_CASE(27);
    CORE_FETCH_CASE(28); CORE_FETCH_CASE(29); CORE_FETCH_CASE(30);
    CORE_FETCH_CASE(31);
    default: return false;
  }
}

#undef CORE_FETCH_CASE

}  // namespace

extern "C" void flash_read(int addr, int* data) {
  *data = static_cast<int>(read_word(static_cast<std::uint32_t>(addr)));
}

extern "C" long long my_mtime() {
  return static_cast<long long>(current_cycle);
}

extern "C" void set_commit(svBit valid, svBit is_ebreak, int code,
                           svBit is_mmio) {
  if (!commits_enabled || !valid) {
    return;
  }
  ++commit_count;
  (void)is_mmio;
  if (is_ebreak && !trap_seen) {
    trap_seen = true;
    trap_code = code;
  }
}

int main(int argc, char** argv) {
#ifdef YSYXSOC_SIM_OUTPUT
  std::cout << std::unitbuf;
#endif
  auto context = std::make_unique<VerilatedContext>();
  context->commandArgs(argc, argv);
  context->randReset(0);

  const std::string image_path = plusarg("+image=", argc, argv);
  const std::string trace_path = plusarg("+trace=", argc, argv);
  const auto core_sel = plusarg_u64("+core-sel=", 1, argc, argv);
  const auto rcu_en = plusarg_u64("+rcu-en=", 1, argc, argv);
  const auto max_cycles = plusarg_u64("+max-cycles=", 30000000, argc, argv);
  const auto reset_cycles = plusarg_u64("+reset-cycles=", 20, argc, argv);
  const auto progress_cycles =
      plusarg_u64("+progress-cycles=", 1000000, argc, argv);

  if (image_path.empty() || !load_image(image_path)) {
#ifdef YSYXSOC_SIM_OUTPUT
    std::cerr << "SIM ERROR: unable to load image: " << image_path << '\n';
#endif
    return 2;
  }
  if (core_sel > 31) {
#ifdef YSYXSOC_SIM_OUTPUT
    std::cerr << "SIM ERROR: core selection must be in [0, 31]\n";
#endif
    return 2;
  }

#ifdef YSYXSOC_SIM_OUTPUT
  std::cout << "Image: " << image_path << " (" << image.size() << " bytes)\n";
  std::cout << "Core select: " << core_sel << '\n';
  std::cout << "RCU control: " << (rcu_en ? "enabled" : "disabled") << '\n';
  std::cout << "Cycle limit: " << max_cycles << '\n';
#endif

  constexpr std::size_t kCpuIdMagicOffset = 370432;
  if (image.size() >= kCpuIdMagicOffset + 12 &&
      read_word(kCpuIdMagicOffset) == 0x00c0ffeeU &&
      read_word(kCpuIdMagicOffset + 8) == 0xdeadbeefU) {
    const auto image_cpu_id = image[kCpuIdMagicOffset + 4];
#ifdef YSYXSOC_SIM_OUTPUT
    std::cout << "Image CPU ID: " << static_cast<unsigned>(image_cpu_id) << '\n';
#endif
    if (image_cpu_id != core_sel) {
#ifdef YSYXSOC_SIM_OUTPUT
      std::cerr << "SIM WARNING: image CPU ID does not match core selection\n";
#endif
    }
  }

  auto top = std::make_unique<VSimTop>(context.get());
  top->clock = 0;
  top->reset = 1;
  top->rcuEn = rcu_en != 0;
  top->coreSel = static_cast<std::uint8_t>(core_sel);
  top->externalPins_uart0_rx = 1;
  top->externalPins_uart1_uart_rx_i = 1;

  auto* const root = top->rootp;
  std::uint64_t fetch_request_cycles = 0;
  std::uint64_t pc_change_count = 0;
  std::uint64_t first_reset_release = UINT64_MAX;
  std::uint64_t first_fetch_request = UINT64_MAX;
  std::uint64_t first_pc_change = UINT64_MAX;
  std::uint64_t first_payload_fetch = UINT64_MAX;
  std::uint64_t psram_write_count = 0;
  std::uint32_t last_psram_write_addr = 0;
  std::uint8_t previous_effective_sel = 0xff;
  std::uint8_t previous_cpu_reset = 0xff;
  std::uint32_t previous_core_pc = 0x30000000U;
  std::uint32_t previous_mcu_pc = 0x30000000U;
  std::uint64_t mcu_pc_change_count = 0;

#if VM_TRACE
  std::unique_ptr<VerilatedFstC> trace;
  if (!trace_path.empty()) {
    context->traceEverOn(true);
    trace = std::make_unique<VerilatedFstC>();
    top->trace(trace.get(), 99);
    trace->open(trace_path.c_str());
#ifdef YSYXSOC_SIM_OUTPUT
    std::cout << "Waveform: " << trace_path << '\n';
#endif
  }
#else
  if (!trace_path.empty()) {
#ifdef YSYXSOC_SIM_OUTPUT
    std::cerr << "SIM WARNING: rebuild with TRACE=1 to enable waveforms\n";
#endif
  }
#endif

  for (current_cycle = 0;
       current_cycle < max_cycles && !trap_seen && !context->gotFinish();
       ++current_cycle) {
    top->reset = current_cycle < reset_cycles;
    commits_enabled = current_cycle >= reset_cycles;

    top->clock = 0;
    top->eval();
#if VM_TRACE
    if (trace) {
      trace->dump(context->time());
    }
#endif
    context->timeInc(1);

    top->clock = 1;
    top->eval();

    const auto effective_sel = static_cast<std::uint8_t>(
        root->SimTop__DOT__asic__DOT__soc__DOT____Vcellinp__cpu__io_coreSel);
    const auto cpu_reset = static_cast<std::uint8_t>(
        root->SimTop__DOT__asic__DOT__soc__DOT__cpuReset);
    const auto selected_core_reset = cpu_reset;
    const auto selected_core_pc = core_pc(root, effective_sel);
    const auto selected_core_fetch_request =
        core_fetch_request(root, effective_sel);
    const auto mcu_pc = static_cast<std::uint32_t>(
        root->SimTop__DOT__asic__DOT__soc__DOT__mcu__DOT__mcu__DOT__ifu__DOT__PC);
    const auto rcu_can_write = static_cast<std::uint8_t>(
        root->SimTop__DOT__asic__DOT__soc__DOT__apb4rcu__DOT__mrcu__DOT__canWrite);
    const auto rcu_core_sel = static_cast<std::uint8_t>(
        root->SimTop__DOT__asic__DOT__soc__DOT__apb4rcu__DOT__mrcu__DOT__cpuSelReg);
    const auto spi_state = static_cast<std::uint8_t>(
        root->SimTop__DOT__asic__DOT__soc__DOT__apbspi__DOT___GEN);
    const auto psram_write =
        root->SimTop__DOT__asic__DOT__soc__DOT__apbpsram__DOT__mpsram__DOT__active &&
        root->SimTop__DOT__asic__DOT__soc__DOT__apbpsram__DOT__mpsram__DOT__write_reg;
    const auto psram_addr = static_cast<std::uint32_t>(
        root->SimTop__DOT__asic__DOT__soc__DOT__apbpsram__DOT__mpsram__DOT__byte_addr_reg);
    if (effective_sel != previous_effective_sel ||
        cpu_reset != previous_cpu_reset) {
#ifdef YSYXSOC_SIM_OUTPUT
      std::cout << "SCHED cycle=" << current_cycle
                << " effective-core=" << static_cast<unsigned>(effective_sel)
                << " cpu-reset=" << static_cast<unsigned>(cpu_reset) << '\n';
#endif
      previous_core_pc = selected_core_pc;
      previous_effective_sel = effective_sel;
      previous_cpu_reset = cpu_reset;
    }
    if (!cpu_reset && first_reset_release == UINT64_MAX) {
      first_reset_release = current_cycle;
    }
    if (selected_core_fetch_request) {
      ++fetch_request_cycles;
      if (first_fetch_request == UINT64_MAX) {
        first_fetch_request = current_cycle;
#ifdef YSYXSOC_SIM_OUTPUT
        std::cout << "CORE" << static_cast<unsigned>(effective_sel)
                  << " first fetch request: cycle=" << current_cycle
                  << " pc=0x" << std::hex << selected_core_pc << std::dec
                  << '\n';
#endif
      }
    }
    if (!selected_core_reset && selected_core_pc != previous_core_pc) {
      ++pc_change_count;
      if (first_pc_change == UINT64_MAX) {
        first_pc_change = current_cycle;
#ifdef YSYXSOC_SIM_OUTPUT
        std::cout << "CORE" << static_cast<unsigned>(effective_sel)
                  << " first PC change: cycle=" << current_cycle
                  << " pc=0x" << std::hex << selected_core_pc << std::dec
                  << '\n';
#endif
      }
    }
    if (!selected_core_reset && selected_core_pc >= 0x80000000U &&
        selected_core_pc < 0x80400000U &&
        first_payload_fetch == UINT64_MAX) {
      first_payload_fetch = current_cycle;
#ifdef YSYXSOC_SIM_OUTPUT
      std::cout << "CORE" << static_cast<unsigned>(effective_sel)
                << " entered payload: cycle=" << current_cycle
                << " pc=0x" << std::hex << selected_core_pc << std::dec
                << '\n';
#endif
    }
    if (psram_write) {
      ++psram_write_count;
      last_psram_write_addr = psram_addr;
    }
    previous_core_pc = selected_core_pc;
    if (mcu_pc != previous_mcu_pc) {
      ++mcu_pc_change_count;
    }
    previous_mcu_pc = mcu_pc;
    if (progress_cycles != 0 && current_cycle != 0 &&
        current_cycle % progress_cycles == 0) {
#ifdef YSYXSOC_SIM_OUTPUT
      std::cout << "PROGRESS cycle=" << current_cycle
                << " effective-core=" << static_cast<unsigned>(effective_sel)
                << " cpu-reset=" << static_cast<unsigned>(cpu_reset)
                << " selected-core-reset="
                << static_cast<unsigned>(selected_core_reset)
                << " selected-core-pc=0x" << std::hex << selected_core_pc
                << std::dec
                << " fetch-req-cycles=" << fetch_request_cycles
                << " pc-changes=" << pc_change_count
                << " mcu-pc=0x" << std::hex << mcu_pc << std::dec
                << " mcu-pc-changes=" << mcu_pc_change_count
                << " rcu-can-write=" << static_cast<unsigned>(rcu_can_write)
                << " rcu-core=" << static_cast<unsigned>(rcu_core_sel)
                << " psram-writes=" << psram_write_count
                << " last-psram-addr=0x" << std::hex
                << last_psram_write_addr << std::dec
                << " spi-state=" << static_cast<unsigned>(spi_state) << '\n';
#endif
    }
#if VM_TRACE
    if (trace) {
      trace->dump(context->time());
    }
#endif
    context->timeInc(1);
  }

  top->final();
#if VM_TRACE
  if (trace) {
    trace->close();
  }
#endif

#ifdef YSYXSOC_SIM_OUTPUT
  std::cout << "Cycles: " << current_cycle << '\n';
  std::cout << "Commit callbacks: " << commit_count << '\n';
  std::cout << "Execution path: effective-core="
            << static_cast<unsigned>(previous_effective_sel)
            << " cpu-reset=" << static_cast<unsigned>(previous_cpu_reset)
            << " selected-core-pc=0x" << std::hex << previous_core_pc
            << std::dec
            << " fetch-req-cycles=" << fetch_request_cycles
            << " pc-changes=" << pc_change_count
            << " psram-writes=" << psram_write_count
            << " last-psram-addr=0x" << std::hex << last_psram_write_addr
            << std::dec << '\n';
  if (first_reset_release != UINT64_MAX) {
    std::cout << "CPU reset released at cycle " << first_reset_release << '\n';
  }
  if (first_payload_fetch != UINT64_MAX) {
    std::cout << "Payload entered at cycle " << first_payload_fetch << '\n';
  }
#endif
  if (trap_seen && trap_code == 0) {
#ifdef YSYXSOC_SIM_OUTPUT
    std::cout << "SIM PASS: HIT GOOD TRAP\n";
#endif
    return 0;
  }
  if (trap_seen) {
#ifdef YSYXSOC_SIM_OUTPUT
    std::cerr << "SIM FAIL: HIT BAD TRAP, code=" << trap_code << '\n';
#endif
    return 1;
  }
  if (context->gotFinish()) {
#ifdef YSYXSOC_SIM_OUTPUT
    std::cerr << "SIM FAIL: simulation finished without a trap result\n";
#endif
    return 1;
  }
#ifdef YSYXSOC_SIM_OUTPUT
  std::cerr << "SIM TIMEOUT: cycle limit reached without a trap result\n";
#endif
  return 3;
}
