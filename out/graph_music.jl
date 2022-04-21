import LinearAlgebra as LinAlg
import SparseArrays

import Graphs
import WAV

using GraphIO

 
function normalized_laplacian_matrix(g::Graphs.SimpleGraph)
    A = Graphs.CombinatorialAdjacency(Graphs.adjacency_matrix(g).+ 0.0)
    Â = Graphs.NormalizedAdjacency(A)
    L̂ = Graphs.NormalizedLaplacian(Â)
    return SparseArrays.sparse(L̂)
end

function normalized_laplacian_spectrum(g::Graphs.SimpleGraph)
    return LinAlg.eigvals(LinAlg.Matrix(normalized_laplacian_matrix(g)))
end

function spectrum_to_frequencies(eigenvalues; zero_freq=440)
    # Compute the frequency for each eigenvalue
    # 0 gets mapped to `zero_freq`,
    # 1 gets mapped to zero_freq + 1 octave (2 * zero_freq),
    # 2 gets mapped to zero_freq + 2 otaves (4 * zero_freq),
    # etc.
    frequency(x) = 2^x * zero_freq 
    return frequency.(eigenvalues)
end

function spectrum_to_amplitude(eigenvalues; zero_freq=440)
    # Compute the frequency for each eigenvalue
    # 0 gets mapped to `zero_freq`,
    # 1 gets mapped to zer o_freq + 1 octave (2 * zero_freq),
    # 2 gets mapped to zero_freq + 2 otaves (4 * zero_freq),
    # etc.
    amplitude(x) = 2^x * zero_freq
    return amplitude.(eigenvalues)
end

#diffrent types of waves

function sine_wave(frequency::Float64; duration::Float64=1.0, Fs::Float64=8e3)
    # Create a range with length `duration` divided into `Fs` samples
    t = 0.0:1/Fs:prevfloat(duration) 
    # Calculate the values of a sine wave with frequency `frequency`
    # over each sample in `t`
    return sin.(2π * frequency * t) * 0.1
end


function square_wave(frequency::Float64; duration::Float64=1.0, Fs::Float64=8e3)
    # Create a range with length `duration` divided into `Fs` samples
    t = 0.0:1/Fs:prevfloat(duration) 
    # Calculate the values of a sine wave with frequency `frequency`
    # over each sample in `t`
    return sign.(cos.(2π * frequency * t)) * 0.1
end

function saw_wave(frequency::Float64; duration::Float64=1.0, Fs::Float64=8e3)
    # Create a range with length `duration` divided into `Fs` samples
    t = 0.0:1/Fs:prevfloat(duration) 
    # Calculate the values of a sine wave with frequency `frequency`
    # over each sample in `t`
    return sign.(cos.(2π * frequency * t)) * 0.1
end

function frequencies_to_tones(frequencies::Vector{Float64}; duration::Float64=1.0, Fs::Float64=8e3)
    return square_wave.(frequencies, duration=duration, Fs=Fs)
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

function write_scale(tones::Vector{Vector{Float64}}, filename::String)
    unique!(tones)
    WAV.wavwrite(tones[1], filename)
    for i in 2:length(tones)
        WAV.wavappend(tones[i], filename)
    end
end


# Change the graph below to listen to a different graph (original: Graphs.SimpleGraph(5, 9))
# NOTE: You can find all the graph generators in Graphs.jl at https://juliagraphs.org/Graphs.jl/dev/generators/#Graph-Generators
G1 = Graphs.SimpleGraph(5, 9)
# Some interesting graphs to try:
# G = Graphs.cycle_graph(8)
# G = Graphs.path_graph(8)
# G = Graphs.barabasi_albert(6, 3)
# G = Graphs.dorogovtsev_mendes(6)

using Graphs
 

graphs =["cubic9.txt"] 



  
#cubic7,   
#"MathematicaGraph2338.txt" 
#"G21.txt" 
#"MathematicaGraph111.txt" 
#"cubic15"
#G42, G29.txt G27
#cubic3
         

for (i, G) in enumerate(graphs) 
    G = Graphs.loadgraph(G, "graph_key", GraphIO.EdgeListFormat())
    G = Graphs.SimpleGraph(G) 
    short_tones = make_tones(G, duration=0.16)
    write_scale(short_tones, "scale$i.wav")
    WAV.wavplay("scale$i.wav")
end 

# Write the graph's "scale" to a WAV file and then play it


short_tones = make_tones(G, duration=0.10)
write_scale(short_tones, "scale12.wav")
WAV.wavplay("scale12.wav")

# Write the graph's "chord" to a WAV file and then play it
#long_tones = make_tones(G)
#write_chord(long_tones, "chord.wav")
#WAV.wavplay("chord.wav")


