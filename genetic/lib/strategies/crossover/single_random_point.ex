defmodule Genetic.Strategies.Crossover.SingleRandomPoint do
  @spec crossover(Genetic.chromosome(), Genetic.chromosome()) :: list(Genetic.chromosome())
  def crossover(parent1, parent2) do
    cx_point = :rand.uniform(length(parent1))
    {hd1, tl1} = Enum.split(parent1, cx_point)
    {hd2, tl2} = Enum.split(parent2, cx_point)
    [hd1 ++ tl2, hd2 ++ tl1]
  end
end
