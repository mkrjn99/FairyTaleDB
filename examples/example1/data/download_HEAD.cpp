// ChatGPT generated

#include <iostream>
#include <cstdlib> // for system()
#include <string>
#include <array>

std::string getGitHeadCommit() {
    std::array<char, 128> buffer;
    std::string result;
    // Use git command to get HEAD commit ID
    FILE* pipe = popen("git rev-parse HEAD", "r");
    if (!pipe) throw std::runtime_error("popen() failed!");
    
    try {
        while (fgets(buffer.data(), buffer.size(), pipe) != nullptr) {
            result += buffer.data();
        }
    } catch (...) {
        pclose(pipe);
        throw;
    }
    pclose(pipe);
    return result;
}

int main() {
    std::string headCommitID = getGitHeadCommit();
    std::cout << "HEAD Commit ID: " << headCommitID << std::endl;
    return 0;
}
