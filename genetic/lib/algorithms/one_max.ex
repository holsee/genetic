defmodule Genetic.Algorithms.OneMax do
  @compile {:inline,
            [
              max_fitness: 0,
              genotype: 0,
              fitness_function: 1
            ]}

  @spec max_fitness :: Genetic.fitness
  def max_fitness, do: 1000

  @spec genotype :: Genetic.chromosome
  def genotype, do: for(_ <- 1..1000, do: Enum.random([0, 1]))

  @spec fitness_function(Genetic.chromosome) :: Genetic.fitness
  def fitness_function(chromosome), do: Enum.sum(chromosome)

  @spec crossover(Genetic.chromosome, Genetic.chromosome) :: list(Genetic.chromosome)
  defdelegate crossover(parent1, parent2), to: Genetic.Strategies.Crossover.SingleRandomPoint
end
