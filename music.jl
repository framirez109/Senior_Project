import LinearAlgebra as LinAlg
import SparseArrays

import Graphs
import GraphRecipes: graphplot
import Plots: savefig
import WAV


function normalized_laplacian_matrix(g::Graphs.SimpleGraph)
    A = Graphs.CombinatorialAdjacency(Graphs.adjacency_matrix(g).+ 0.0)
    Â = Graphs.NormalizedAdjacency(A) 
    L̂ = Graphs.NormalizedLaplacian(Â) 
    return SparseArrays.sparse(L̂)
end 


function normalized_laplacian_spectrum(g::Graphs.SimpleGraph)
    return LinAlg.eigvals(LinAlg.Matrix(normalized_laplacian_matrix(g))) 
end

function spectrum_to_frequencies(eigenvalues::Vector{Float64}; zero_freq::Float64=440.0)
    # Compute the frequency for each eigenvalue
    # 0 gets mapped to `zero_freq`,
    # 1 gets mapped to zero_freq + 1 octave (2 * zero_freq),
    # 2 gets mapped to zero_freq + 2 otaves (4 * zero_freq),
    # etc.
    frequency(x) = 2^x * zero_freq
    return frequency.(eigenvalues)
end

function sine_wave(frequency::Float64; duration::Float64=1.0, Fs::Float64=8e3)
    # Create a range with length `duration` divided into `Fs` samples
    t = 0.0:1/Fs:prevfloat(duration)
    # Calculate the values of a sine wave with frequency `frequency`
    # over each sample in `t`
    return sin.(2π * frequency * t) * 0.1
end

function frequencies_to_tones(frequencies::Vector{Float64}; duration::Float64=1.0, Fs::Float64=8e3)
    return sine_wave.(frequencies, duration=duration, Fs=Fs)
end

function make_tones(g::Graphs.SimpleGraph; duration::Float64=1.0, Fs::Float64=8e3)
    # NOTE: Repeated eigenvalues in the spectrum result in repeated tones
    spectrum = normalized_laplacian_spectrum(g)
    frequencies = spectrum_to_frequencies(spectrum)
    return frequencies_to_tones(frequencies, duration=duration, Fs=Fs)
end

function write_chord(tones::Vector{Vector{Float64}}, filename::String)
    chord = sum.(zip(tones...))
    WAV.wavwrite(chord, filename)
end


# Generate six random graphs on four vertices with increasing numbers of edges
for i in 1:10
    path = "out/$i/"
    mkpath(path)
 
    # Create a random graph on 4 vertices
    G = Graphs.SimpleGraph(10, i) 

    # Generate the graph's chord
    tones = make_tones(G)
    write_chord(tones, "$path/chord$i.wav")

    # Plot the graph and save the plot to a file
    graphplot(G)
    savefig("$path/G$i.png")
end