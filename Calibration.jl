using FFTW: fft
using DelimitedFiles: writedlm, readdlm
using LinearAlgebra: dot

function calibrate(noise::String, instName::String, instIndex::String="", prefix::String="", S=48000::Int64)
    whiteNoise = readdlm(noise) # read in white noise
    inName = string(prefix, instName, instIndex, ".txt")
    instrument = readdlm(inName)
    whiteNoise = whiteNoise[S+1:length(whiteNoise)]

    wNLength = length(whiteNoise)

    avgWN = Vector{Float32}(undef, wNLength ÷ 7)
    avgWN .= 0

    for i in 1:wNLength÷S÷2
        avgWN .+= whiteNoise[(((i-1)*wNLength÷7)+1):(i*wNLength÷7)]
    end

    avgWN ./ (wNLength ÷ S ÷ 2)
    avgWnLen = length(avgWN)

    whiteNoiseFFT = abs.(2 / avgWnLen * fft(avgWN))

    instLength = length(instrument)
    instFFT = abs.(2 / instLength * fft(instrument))

    interpolatedWhiteNoise = Vector{Float32}(undef, instLength)
    interpolatedWhiteNoise .= 0

    for i in 1:instLength
        interpolatedPosition = Int(floor((avgWnLen / instLength) * (i - 1))) + 1
        interpolatedWhiteNoise[i] = whiteNoiseFFT[interpolatedPosition]
    end

    calibratedInstrument = interpolatedWhiteNoise .* instFFT
    return calibratedInstrument
end

function calibrate_controls()
    instruments = ["clarinet", "tenor_sax", "bass_clar","piano"]
    instrumentTimbre = ["1", "2", "3"]
    for instrument in instruments
        for timbre in instrumentTimbre
            println("Calibrating $instrument$timbre...")
            calibratedInstrument = calibrate("instrument/src/whiteNoiseControl.txt", instrument, timbre, "instrument/src/")
            println("Writing $instrument$timbre to file...")
            writedlm(string("instrument/controlsFFT/", instrument, timbre, "_calibrated.txt"), calibratedInstrument)
        end
    end
end

function vector_correlation(in, cntrl)
    input = vec(in);
    inputLength = length(input);
    control = vec(cntrl);
    controlLength = length(control);
    interpolatedInput = Vector{Float32}(undef, controlLength);

    for i in 1:controlLength
        interpolatedPosition = Int(floor((inputLength / controlLength) * (i - 1))) + 1
        interpolatedInput[i] = input[interpolatedPosition]
    end

    dot_product = abs(dot(interpolatedInput, control));
    magnitude1 = sqrt(sum(abs2,interpolatedInput));
    magnitude2 = sqrt(sum(abs2, control));
    coeff = dot_product / (magnitude1 * magnitude2);
    return coeff
end

function analyze_instrument()
    in_fft = calibrate("instrument/whiteNoiseIn.txt", "instrument/inst_in");
    instruments = ["clarinet", "tenor_sax", "bass_clar", "piano"];
    instrumenttimbre = ["1", "2", "3"];
    instrument_coeff = 0;
    instrument_name = "clarinet";
    #upon failure, will probably return instrument as clarinet with 0% confidence.
    for instrument in instruments
        for timbre in instrumenttimbre
            control = readdlm(string("instrument/controlsFFT/", instrument, timbre, "_calibrated.txt"));
            temp_coeff = vector_correlation(in_fft, control);
            println("$instrument$timbre confidence: $temp_coeff");
            if (temp_coeff > instrument_coeff) 
                instrument_coeff = temp_coeff;
                instrument_name = instrument;
            end
        end
    end
    println("")
    confidence = instrument_coeff;
    round(confidence,digits=3);
    return instrument_name, confidence;
end