#signal comparison and confidence
using LinearAlgebra
using DelimitedFiles
using FFTW: fft

function vector_correlation(vector1, vector2)
    dot_product = abs(dot(vector1, vector2));
    magnitude1 = sqrt(sum(abs2,vector1));
    magnitude2 = sqrt(sum(abs2, vector2));
    coeff = dot_product / (magnitude1 * magnitude2);
    return coeff
end

function signal_comparison(instruments)
    input = abs(fft(readdlm("input.txt")))
    input = input[1:length(input)/2]
    instrument_coeff = 0
    instrument_name = "sugondeez"

    for i in 1:length(instruments)
        control = abs(fft(readdlm(instruments[(i-1)/3] + (i-1)%3 + ".txt")))
        control = control[1:length(input)/2]
        temp_coeff = vector_correlation(control, input)
        if (temp_coeff > instrument_coeff) {
            instrument_coeff = temp_coeff
            instrument_name = instruments[(i-1)/3]
        }
    end

    return instrument_name, instrument_coeff
end