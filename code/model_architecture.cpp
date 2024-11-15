// As per https://github.com/mkrjn99/FairyTaleDB/blob/14653bf6353e823c4e6037a96f71c50f88d0df2e/data/agi_hypothesis.md
#include <vector>
#include <unique_ptr>
using namespace std;

enum class NodeType {
    LEAF,
    NON_LEAF
};

int NUM_TOTAL_LAYERS = 5;
int MIN_NODES_IN_LAYER = 10;
int VARIANCE_NODES_IN_LAYER = 5;

int generateNumThisLayerNodes(int numRemainingLayers) {
    if(numRemainingLayers==0) {
        return 0;
    }
    if(numRemainingLayers==NUM_TOTAL_LAYERS) {
        return 1;
    }
    return MIN_NODES_IN_LAYER+int(random()%VARIANCE_NODES_IN_LAYER);
}

struct Layer {
    unique_ptr<Layer> m_nextLayer;
    vector<Node> m_nodes;

    Layer(int numRemainingLayers);

};

struct Node {
    unique_ptr<Layer> m_nextLayer;
    vector<int> m_trustScores; // a value between 1 to 1e7, initially 1e4
    int ahr; // ahr starts at 1e4 and goes upto 2e8
    int pwsum; // pwsum is short for 'pledged wealth step up multiple'

    Node(unique_ptr<Layer> m_nextLayer): m_nextLayer(m_nextLayer) {
        assert(m_nextLayer.get() != nullptr);
        m_trustScores.resize(m_nextLayer->m_nodes().size(), random()%int(1e4));

        ahr = int(1e4);
        pwsum = int(m_trustScores.size()*1e4/2); // this is the expected value of the sum of trust scores
    }

    void adjust() {
        // TODO: adjust ahr and pwsum such that 'loss function' is as close to 0 as possible
        // ideally ahr should keep going up, and pwsum should keep going down with it

        ahr+=int(ahr*0.1); // node gives itself a 10% hike in salary, LOL
        
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
        // TODO: actually compute loss function
        throw;
    }
};

Layer::Layer(int numRemainingLayers) {
    numThisLayerNodes = generateNumThisLayerNodes(numRemainingLayers);
    if(numThisLayerNodes == 0){
        return;
    }
    m_nextLayer = make_unique(numRemainingLayers-1);

    for(int i=0;i<numThisLayerNodes;++i){
        m_nodes.emplace_back(m_nextLayer);
    }
}

int main() {
    Layer root(NUM_TOTAL_LAYERS);
}