#include <benchmark/benchmark.h>

#include "project_name/project_core.hpp"

static void BenchmarkGreeting(benchmark::State& state) {
  for (auto _ : state) {
    benchmark::DoNotOptimize(project_name::greeting());
  }
}

BENCHMARK(BenchmarkGreeting);
