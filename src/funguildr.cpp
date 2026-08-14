// By Brendan Furneaux
// Reimplementation of Guilds_v1.1.py by Zewei Song

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <Rcpp.h>
#include <limits>
#include <string>
#include <unordered_map>
#include <vector>

// [[Rcpp::plugins(cpp11)]]

struct Match
{
  int level;
  int index;
};

// Match unique taxonomy keys to database search keys.
//
// searchkeys / taxonomicLevel describe the FUNGuild (or NEMAGuild) database.
// For each taxkey, candidate tokens are each rank and each consecutive pair of
// ranks (the two shapes produced by replacing the first space/underscore in a
// taxon name). Among hits, the highest taxonomicLevel wins; ties keep the
// earliest database row.
//
// [[Rcpp::export]]
Rcpp::DataFrame match_taxkeys_cpp(Rcpp::CharacterVector taxkeys,
                                  Rcpp::CharacterVector searchkeys,
                                  Rcpp::IntegerVector taxonomicLevel)
{
  const int n_search = searchkeys.size();
  if (taxonomicLevel.size() != n_search)
  {
    Rcpp::stop("searchkeys and taxonomicLevel must have the same length");
  }

  std::unordered_map<std::string, Match> db_map;
  db_map.reserve(static_cast<size_t>(n_search));

  for (int i = 0; i < n_search; ++i)
  {
    if (searchkeys[i] == NA_STRING)
    {
      continue;
    }
    int level = taxonomicLevel[i];
    if (level == NA_INTEGER)
    {
      level = std::numeric_limits<int>::min();
    }
    const std::string key = Rcpp::as<std::string>(searchkeys[i]);
    const auto it = db_map.find(key);
    if (it == db_map.end() || level > it->second.level)
    {
      db_map[key] = Match{level, i};
    }
  }

  const int n_tax = taxkeys.size();
  std::vector<std::string> out_taxkey;
  std::vector<std::string> out_searchkey;
  out_taxkey.reserve(static_cast<size_t>(n_tax));
  out_searchkey.reserve(static_cast<size_t>(n_tax));

  for (int t = 0; t < n_tax; ++t)
  {
    if (taxkeys[t] == NA_STRING)
    {
      continue;
    }
    const std::string tk = Rcpp::as<std::string>(taxkeys[t]);

    std::vector<std::string> ranks;
    std::string rank;
    for (size_t i = 0; i <= tk.size(); ++i)
    {
      if (i == tk.size() || tk[i] == '@')
      {
        if (!rank.empty())
        {
          ranks.push_back(rank);
          rank.clear();
        }
      }
      else
      {
        rank.push_back(tk[i]);
      }
    }

    bool found = false;
    Match best{std::numeric_limits<int>::min(),
               std::numeric_limits<int>::max()};

    auto consider = [&](const std::string &cand)
    {
      const auto it = db_map.find(cand);
      if (it == db_map.end())
      {
        return;
      }
      const Match &m = it->second;
      if (!found || m.level > best.level ||
          (m.level == best.level && m.index < best.index))
      {
        best = m;
        found = true;
      }
    };

    for (size_t i = 0; i < ranks.size(); ++i)
    {
      consider(std::string("@") + ranks[i] + "@");
      if (i + 1 < ranks.size())
      {
        consider(std::string("@") + ranks[i] + "@" + ranks[i + 1] + "@");
      }
    }

    if (found)
    {
      out_taxkey.push_back(tk);
      out_searchkey.push_back(
          Rcpp::as<std::string>(searchkeys[best.index]));
    }
  }

  return Rcpp::DataFrame::create(
      Rcpp::Named("taxkey") = out_taxkey,
      Rcpp::Named("searchkey") = out_searchkey,
      Rcpp::Named("stringsAsFactors") = false);
}
