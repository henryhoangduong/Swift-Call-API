//
//  ContentView.swift
//  API
//
//  Created by mac on 12/12/2567 BE.
//

import SwiftUI

struct ContentView: View {
    @State var user: GithubUser?
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fit).clipShape(Circle()).frame(width: 120, height: 120)
            } placeholder: {
                Circle().foregroundColor(.secondary).frame(width: 120, height: 120)
            }
            Text(user?.login ?? "Login placeholder").bold().font(.title3)
            Text(user?.bio ?? "Bio placeholder").padding()
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch {
                print("Error")
            }
        }
    }

    func getUser() async throws -> GithubUser {
        let endpoint = "https://api.github.com/users/henryhoangduong"
        guard let url = URL(string: endpoint) else { throw GHError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw GHError.invalidResponse }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            try print(decoder.decode(GithubUser.self, from: data))
            return try decoder.decode(GithubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct GithubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
