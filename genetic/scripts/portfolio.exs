defmodule Portfolio do

  alias Types.Chromosome

  @target_fitness 180

  @impl true
  def genotype do
    genes = for _ <- 1..10, do: {:rand.uniform(10), :rand.uniform(10)}
    %Chromosome{genes: genes, size: 10}
  end

  @impl true
  def fitness_function(chromosome) do
    chromosome
      |> Enum.map(fn {roi, risk} -> 2 * roi - risk  end)
      |> Enum.sum()
  end

  @impl true
  def terminate?(population, generation, _) do
    Enum.max_by(population, &fitness_function/1) > @target_fitness
  end
end

soln = Genetic.run(Portfolio, population_size: 1_000)
IO.write("\n")
IO.inspect(soln)
