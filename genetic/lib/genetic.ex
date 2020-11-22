defmodule Genetic do
  alias Types.Chromosome
  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end

  def evaluate(population, fitness_function, _opts \\ []) do
    population
      |> Enum.map(
        fn chromosome ->
          fitness = fitness_function.(chromosome)
          age = chromosome.age + 1
          %{chromosome | fitness: fitness, age: age}
        end
        )
      |> Enum.sort_by(fitness_function, &>=/2)
  end

  def select(population, _opts \\ []) do
    population
      |> Enum.chunk_every(2)
      |> Enum.map(&List.to_tuple/1)
  end

  def crossover(population, _opts \\ []) do
    population
      |> Enum.reduce([], fn {p1, p2}, acc ->
        cx_point = :rand.uniform(length(p1.genes))
        {{h1, t1}, {h2, t2}} = {Enum.split(p1.genes, cx_point), Enum.split(p2.genes, cx_point)}
        {c1, c2} = {%Chromosome{ genes: h1 ++ t2}, %Chromosome{ genes: h2 ++ t1}}
        [c1 , c2 | acc]
      end )
  end

  def mutation(population, _opts \\ []) do
    population
      |> Enum.map(fn chromosome ->
        if :rand.uniform() <= 0.05 do
          %Chromosome{genes: Enum.shuffle(chromosome.genes)}
        else
          chromosome
        end
      end)
  end

  def run(problem, opts \\ []) do
    initialize(&problem.genotype/0, opts)
      |> evolve(problem, 0, 0, 0, opts)
  end

  def evolve(population, problem, generation, last_max_fitness, temperature, opts \\ []) do
    population = evaluate(population, &problem.fitness_function/1, opts)
    best = Enum.max_by(population, &problem.fitness_function/1).fitness
    temperature = 0.8 * (best - last_max_fitness)

    IO.write("\rCurrent Best: #{best}")
    if problem.terminate?(population, generation, temperature) do
      hd(population)
    else
      generation = generation + 1
      population
        |> select(opts)
        |> crossover(opts)
        |> mutation(opts)
        |> evolve(problem, generation, best, temperature, opts)
    end
  end
end
