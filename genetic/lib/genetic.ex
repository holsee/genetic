defmodule Genetic do
  @type mutation_rate :: non_neg_integer()
  @type population_size :: non_neg_integer()
  @type chromosome :: list()
  @type population :: list(chromosome())
  @type genotype :: (() -> chromosome())
  @type fitness :: integer()
  @type fitness_function :: (chromosome() -> fitness())
  @type algorithm :: module()

  @typedoc """
  Options for tuning genetic algorithm operation.
  """
  @type hyper_params :: %{
    population_size: population_size,
    mutation_rate: mutation_rate
  }
  @default_hyper_params %{
    population_size: 100,
    mutation_rate: 5
  }

  @spec run(algorithm, hyper_params) :: chromosome
  def run(algo, hyper_params \\ @default_hyper_params) do
    population = initialize(algo, hyper_params.population_size)
    evolve(population, algo, hyper_params, :os.system_time(:millisecond))
  end

  @spec initialize(algorithm, population_size) :: population
  def initialize(algo, population_size) do
    for _ <- 1..population_size, do: algo.genotype()
  end

  @spec evolve(population, algorithm, hyper_params, timestamp :: integer(), generation :: integer()) :: population
  def evolve(population, algo, hyper_params, ts, generation \\ 0) do
    [{best, best_fitness} | _] = population_eval = evaluate(population, algo)
    IO.write("\rAlgo: #{algo} @ #{inspect hyper_params} | TS: #{:os.system_time(:millisecond) - ts}ms | Generation: #{generation} | Fitness: #{best_fitness}")

    if best_fitness >= algo.max_fitness() do
      best
    else
      population =
        population_eval
        |> Enum.map(&elem(&1, 0))

      population
      |> select()
      |> crossover(algo)
      |> mutation(hyper_params.mutation_rate)
      |> evolve(algo, hyper_params, ts, generation + 1)
    end
  end

  @spec evaluate(population, algorithm) :: list({chromosome, fitness})
  def evaluate(population, algo) do
    population
    |> Enum.map(&{&1, algo.fitness_function(&1)})
    |> Enum.sort_by(fn {_, fitness} -> fitness end, &>=/2)
  end

  @spec select(population) :: population
  def select(population) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  @spec crossover(population, algorithm) :: population
  def crossover(population, algo) do
    Enum.reduce(population, [], fn {p1, p2}, acc ->
      [ch0, ch1] = algo.crossover(p1, p2)
      [ch0, ch1 | acc]
    end)
  end

  @spec mutation(population, mutation_rate) :: chromosome
  def mutation(population, mutation_rate) do
    Enum.map(population, fn chromosome ->
      if :rand.uniform(100) <= mutation_rate do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end
