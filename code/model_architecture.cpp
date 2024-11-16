// Loosely based on https://github.com/mkrjn99/FairyTaleDB/blob/14653bf6353e823c4e6037a96f71c50f88d0df2e/data/agi_hypothesis.md, decentralisation will be hard to implement, so just trying centralised first.
#include <vector>
#include <memory>
#include <utility>
#include <cassert>
using namespace std;

enum class NodeType {
    LEAF,
    NON_LEAF
};

int NUM_TOTAL_LAYERS = 5;
int MIN_NODES_IN_LAYER = 10;
int VARIANCE_NODES_IN_LAYER = 5;

int INPUT_VECTOR_SIZE = 10;

int MIN_AHR = 128;
int MAX_AHR = 524287; // 2^19-1

int MAX_TRUST_SCORE = 524287;

int MAX_INPUT_VALUE = 2047;
int MAX_CONFIDENCE_SCORE = 2047;

vector<int> input;

int generateNumThisLayerNodes(int numRemainingLayers) {
    if(numRemainingLayers==0) {
        return 0;
    }
    if(numRemainingLayers==NUM_TOTAL_LAYERS) {
        return 1;
    }
    return MIN_NODES_IN_LAYER+int(random()%VARIANCE_NODES_IN_LAYER);
}

struct Node;

struct Layer {
    unique_ptr<Layer> m_nextLayer;
    vector<Node> m_nodes;

    Layer(int numRemainingLayers);

};

struct Node {
    unique_ptr<Layer> m_nextLayer;
    vector<int> m_trustScores; // a value between 0 to 524287, initially 128
    vector<double> pw;
    int ahr; // ahr starts at 128 and goes upto 524287
    int pwsum; // pwsum is short for 'pledged wealth step up multiple'
    int lastInferenceScore; // stored last inference score calculated by the infer() function

    Node(unique_ptr<Layer> &&m_nextLayer): m_nextLayer(std::move(m_nextLayer)) {
        ahr = MIN_AHR;
        int trustScoresSize = (m_nextLayer.get() == nullptr) ? INPUT_VECTOR_SIZE : m_nextLayer->m_nodes.size();

        m_trustScores.resize(trustScoresSize, random()%int(MAX_TRUST_SCORE/2));
        pw.resize(trustScoresSize);

        pwsum = int(trustScoresSize*MAX_AHR/4); // this is the expected value of the sum of trust scores
    }

    void adjust() {
        // adjust ahr and pwsum such that 'loss function' is as close to 0 as possible
        // ideally ahr should keep going up, and pwsum should keep going down with it

        if(m_nextLayer.get() == nullptr) {
            return;
        }

        int lo = 1, hi = pwsum*2;

        while(lo-hi>1) { // lower bound predicate search, who thinks competitive coding is BS?
            pwsum = (lo+hi)/2;
            double lf = calculateLossFunction();
            
            if(lf>0) {
                hi = pwsum;
            } else {
                lo = pwsum;
            }
        }
        pwsum = hi;
    }

    double calculateLossFunction(){
        auto pwsu = double(ahr)*pwsum;
        double pw_total = 0;
        int trustScoreTotal = 0;
        for(int i=0;i<m_trustScores.size();++i) {
            trustScoreTotal += m_trustScores[i];
            pw[i] = (m_trustScores[i]/pwsu)/100*m_trustScores[i];
            pw_total += pw[i];
        }
        // we are currently not using the vector pw, just taking its sum,
        // but I have 'faith' that it will be useful, somehow

        return (trustScoreTotal-pw_total);
    }

    int infer() {
        assert(input.size() == INPUT_VECTOR_SIZE);
        int64_t weightedSum = 0;
        int64_t totalTrustScore = 0;

        for(int i=0;i<m_trustScores.size();++i) {
            totalTrustScore += m_trustScores[i];
            if(m_nextLayer.get() == nullptr) {
                weightedSum += input[i]*m_trustScores[i];
                continue;
            }
            weightedSum += m_nextLayer->infer(input)*m_trustScores[i];
        }

        int result = weightedSum/totalTrustScore;

        lastInferenceScore = result;
    }

    void receiveFeedbackOnLastInference(int expectedInferenceScore) {
        ahr+=int(ahr*(10.0+random()%11)/100); // node gives itself a 10-20% random hike in salary, LOL

        double reductionPercent = abs(expectedInferenceScore-lastInferenceScore)/2047.0*100;
        ahr-=(ahr*reductionPercent);
    }
};

Layer::Layer(int numRemainingLayers) {
    int numThisLayerNodes = generateNumThisLayerNodes(numRemainingLayers);
    if(numThisLayerNodes == 0){
        return;
    }
    m_nextLayer = std::make_unique<Layer>(numRemainingLayers-1);

    for(int i=0;i<numThisLayerNodes;++i){
        m_nodes.emplace_back(std::move(m_nextLayer));
    }
}

int main() {
    srand(time(nullptr));
    Layer root(NUM_TOTAL_LAYERS);
}
