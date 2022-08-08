using LinearAlgebra

vector1 = [0,1,1,1,1,1,1,1]
vector2 = [0,1,1,1,1,1,1,1]
function vector_correlation(vector1, vector2)
    dot_product = abs(dot(vector1, vector2));
    magnitude1 = sqrt(sum(abs2,vector1));
    magnitude2 = sqrt(sum(abs2, vector2));
    coeff = dot_product / (magnitude1 * magnitude2);
    return coeff
end
coeff = vector_correlation(vector1, vector2)
print(coeff)
