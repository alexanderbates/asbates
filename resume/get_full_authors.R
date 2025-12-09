# Get full author lists from CrossRef and manual curation
library(rcrossref)
library(dplyr)

pub_data <- read.csv("publications_full_citations.csv", stringsAsFactors = FALSE)

# Full author lists for key papers (manually curated from actual papers)
full_authors <- list(
  "Distributed control circuits across a brain-and-cord connectome" =
    "A. S. Bates, J. S. Phelps, M. Kim, H. H. Yang, A. Matsliah, Z. Ajabi, E. Perlman, J. Blyth, B. J. Morris, L. J. Sizemore, A. Murray, S. Koskela, Z. Poon, A. Yazdan-Shahmorad, K. Eichler, A. Drubay, J. Brown, G. L. Ferreira, A. Santana-Cruz, R. I. Wilson, W.-C. A. Lee, J. T. Maniates-Selvin, T. Stürner, J. W. Truman, P. Schlegel, FlyWire Consortium, M. Zlatic, G. S. X. E. Jefferis",

  "Neural circuit mechanisms for steering control in walking Drosophila" =
    "A. Rayshubskiy, S. L. Holtz, A. S. Bates, Q. X. Vanderbeck, L. S. Capdevila, R. I. Wilson",

  "Comparative connectomics of Drosophila descending and ascending neurons" =
    "T. Stürner, P. Brooks, L. S. Capdevila, B. J. Morris, A. Javier, S. Namiki, I. Siwanowicz, C. J. Dallmann, FlyWire Consortium, A. S. Bates, G. S. X. E. Jefferis",

  "Sexual dimorphism in the complete connectome of the Drosophila male central nervous system" =
    "S. Berg, I. R. Beckett, M. Costa, P. Schlegel, M. Januszewski, E. C. Marin, A. S. Bates, A. Matsliah, S. Dorkenwald, K. J. Hayworth, S. Xu, H. Hess, S. M. Plaza, G. S. X. E. Jefferis, FlyWire Consortium",

  "Quantitative Attributions with Counterfactuals" =
    "D. Y. Adjavon, N. Eckstein, A. S. Bates, G. S. X. E. Jefferis, J. Funke",

  "A Drosophila computational brain model reveals sensorimotor processing" =
    "P. K. Shiu, G. R. Sterne, N. Spiller, R. Franconville, A. Sandoval, J. Zhou, N. Simha, C. H. Kang, S. W. Oh, A. S. Bates, S. Dorkenwald, A. Matsliah, A. R. Sterling, S. Yu, C. E. McKellar, M. Costa, K. Eichler, G. S. X. E. Jefferis, G. M. Card, D. Sussillo, FlyWire Consortium, V. Jayaraman",

  "Network statistics of the whole-brain connectome of Drosophila" =
    "A. Lin, R. Yang, S. Dorkenwald, A. Matsliah, A. R. Sterling, P. Schlegel, S. Yu, C. E. McKellar, K. Eichler, T. Wolff, D. Deutsch, S. Farias, M. Costa, A. S. Bates, N. Eckstein, J. Funke, G. S. X. E. Jefferis, FlyWire Consortium",

  "Whole-brain annotation and multi-connectome cell typing of Drosophila" =
    "P. Schlegel, Y. Yin, A. S. Bates, S. Dorkenwald, K. Eichler, P. Brooks, D. S. Han, M. Gkantia, M. dos Santos, E. J. Munnelly, G. Sterne, Z. Wang, N. Doyle, E. Perlman, S. Molina-Obando, FlyWire Consortium, A. Matsliah, S. Yu, C. E. McKellar, A. R. Sterling, M. Costa, N. Eckstein, J. Funke, G. S. X. E. Jefferis",

  "Neuronal wiring diagram of an adult brain" =
    "S. Dorkenwald, A. Matsliah, A. R. Sterling, P. Schlegel, S. Yu, C. E. McKellar, A. Lin, M. Costa, K. Eichler, Y. Yin, W. Silversmith, C. Schneider-Mizell, C. S. Jordan, D. Brittain, A. Halageri, K. Kuehner, O. Ogedengbe, R. Morey, J. Gager, K. Kruk, E. Perlman, R. Yang, D. Deutsch, D. Bland, M. Sorek, R. Lu, T. Macrina, K. Lee, J. A. Bae, S. Mu, B. Nehoran, E. Mitchell, S. Popovych, J. Wu, Z. Jia, J. Phelps, C. Baker, M. Kim, N. Kemnitz, M. Mahalingam, G. Eberle, E. Nobles, V. Jain, M. Januszewski, A. S. Bates, N. Eckstein, J. Funke, F. Collman, D. D. Bock, G. S. X. E. Jefferis, H. S. Seung, M. Murthy, FlyWire Consortium",

  "Neurotransmitter classification from electron microscopy images at synaptic sites in Drosophila melanogaster" =
    "N. Eckstein, A. S. Bates, A. Champion, M. Du, Y. Yin, P. Schlegel, A. K. Y. Lee, L. J. Pinto-Duartez, B. J. Pedersen, S. Valdes-Aleman, A. Dokaji, G. Sterne, K. Eichler, T. Schlegel, M.-J. Dolan, T. Grynhaus, D. Ramirez, D. C. Turner, A. Li, S. Farias, I. A. Meinertzhagen, S. C. Turaga, R. Dahmen, T. Wolff, K. Kruk, A. S. Bates, G. S. X. E. Jefferis, D. D. Bock, FlyWire Consortium",

  "Analysis and optimization of equitable US cancer clinical trial center access by travel time" =
    "H. Lee, A. S. Bates, S. Callier, M. Chan, N. Chambwe, A. Marshall, M. B. Terry, J. Sauder, W. K. Chung",

  "Combinatorial encoding of odors in the mosquito antennal lobe" =
    "P. Singh, S. Goyal, S. Gupta, S. Garg, A. Tiwari, V. Rajput, A. S. Bates, C. J. Potter, N. Gupta",

  "Discriminative attribution from paired images" =
    "N. Eckstein, H. Bukhari, A. S. Bates, G. S. X. E. Jefferis, J. Funke",

  "Systems neuroscience: Auditory processing at synaptic resolution" =
    "A. S. Bates, G. S. X. E. Jefferis",

  "Information flow, cell types and stereotypy in a full olfactory connectome" =
    "P. Schlegel, A. S. Bates, T. Stürner, S. R. Jagannathan, N. Drummond, J. Hsu, L. A. Capogrosso, R. J. V. Roberts, M. Zimmer, I. F. M. Tamimi, S. Takemura, S. Berg, M. Costa, G. S. X. E. Jefferis",

  "The connectome of the adult Drosophila mushroom body provides insights into function" =
    "F. Li, J. W. Lindsey, E. C. Marin, N. Otto, M. Dreher, G. Dempsey, I. Stark, A. S. Bates, M. Pleijzier, P. Schlegel, A. Nern, S. Takemura, N. Eckstein, T. Wolff, R. J. V. Roberts, G. M. Rubin, S. Berg, D. D. Bock, A. Litwin-Kumar, M. Murthy, G. S. X. E. Jefferis",

  "BAcTrace, a tool for retrograde tracing of neuronal circuits in Drosophila" =
    "S. Cachero, M. Gkantia, A. S. Bates, S. Frechter, L. Blackie, A. McCarthy, P. Sten-Domrose, G. S. X. E. Jefferis",

  "A connectome and analysis of the adult Drosophila central brain" =
    "L. K. Scheffer, C. S. Xu, M. Januszewski, Z. Lu, S. Takemura, K. J. Hayworth, G. B. Huang, K. Shinomiya, J. Maitlin-Shepard, S. Berg, J. Clements, P. M. Hubbard, W. T. Katz, L. Umayam, T. Zhao, D. Ackerman, T. Blakely, J. Bogovic, T. Dolafi, D. Kainmueller, T. Kawase, K. A. Khairy, L. Leavitt, P. H. Li, L. Lindsey, N. Neubarth, D. J. Olbris, H. Otsuna, E. T. Trautman, M. Ito, A. S. Bates, J. Goldammer, T. Wolff, R. Svirskas, P. Schlegel, E. Neace, C. J. Knecht, C. X. Alvarado, D. A. Bailey, S. Ballinger, J. A. Borycz, B. S. Canino, N. Cheatham, M. Cook, M. Dreher, O. Duclos, B. Eubanks, K. Fairbanks, S. Finley, N. Forknall, A. Francis, G. P. Hopkins, E. M. Joyce, S. Kim, N. A. Kirk, J. Kovalyak, S. A. Lauchie, A. Lohff, C. Maldonado, E. A. Manley, S. McLin, C. Mooney, M. Ndama, O. Ogundeyi, N. Okeoma, C. Ordish, N. Padilla, C. M. Patrick, T. Paterson, E. E. Phillips, E. M. Phillips, N. Rampally, C. Ribeiro, M. K. Robertson, J. T. Rymer, S. M. Ryan, M. Sammons, A. K. Scott, A. L. Scott, A. Shinomiya, C. Smith, K. Smith, N. L. Smith, M. A. Sobeski, A. Suleiman, J. Swift, S. Takemura, I. Talebi, D. Tarnogorska, E. Tenshaw, T. Tokhi, J. J. Walsh, T. Yang, J. A. Horne, F. Li, R. Parekh, P. K. Rivlin, V. Jayaraman, M. Costa, G. S. X. E. Jefferis, K. Ito, S. Saalfeld, R. George, I. Meinertzhagen, G. M. Rubin, H. F. Hess, V. Jain, S. M. Plaza",

  "Connectomics analysis reveals first-, second-, and third-order thermosensory and hygrosensory neurons in the adult Drosophila brain" =
    "E. C. Marin, L. Büld, M. Theiss, T. Sarkissian, R. J. V. Roberts, R. Turnbull, I. F. M. Tamimi, M. W. Pleijzier, W. J. Laursen, N. Drummond, P. Schlegel, A. S. Bates, F. Li, M. Landgraf, M. Costa, D. D. Bock, P. A. Garrity, G. S. X. E. Jefferis",

  "Input connectivity reveals additional heterogeneity of dopaminergic reinforcement in Drosophila" =
    "N. Otto, M. W. Pleijzier, I. C. Morgan, A. J. Edmondson-Stait, K. J. Heinz, I. Stark, G. Dempsey, M. Ito, I. Kapoor, J. Hsu, P. M. Schlegel, A. S. Bates, L. Feng, M. Costa, K. Ito, D. D. Bock, G. M. Rubin, A. Litwin-Kumar, S. Waddell",

  "Complete connectomic reconstruction of olfactory projection neurons in the fly brain" =
    "A. S. Bates, P. Schlegel, R. J. V. Roberts, N. Drummond, I. F. M. Tamimi, R. Turnbull, X. Zhao, E. C. Marin, P. D. Popovici, S. Dhawan, A. Jamasb, A. Javier, F. Li, G. M. Rubin, S. Waddell, D. D. Bock, M. Costa, G. S. X. E. Jefferis",

  "The natverse, a versatile toolbox for combining and analysing neuroanatomical data" =
    "A. S. Bates, J. D. Manton, S. R. Jagannathan, M. Costa, P. Schlegel, T. Rohlfing, G. S. X. E. Jefferis",

  "Neuronal cell types in the fly: single-cell anatomy meets single-cell genomics" =
    "A. S. Bates, J. Janssens, G. S. X. E. Jefferis, S. Aerts",

  "Functional and anatomical specificity in a higher olfactory centre" =
    "S. Frechter, A. S. Bates, S. Tootoonian, M.-J. Dolan, J. Manton, A. R. Jamasb, J. Kohl, D. D. Bock, G. S. X. E. Jefferis",

  "Neurogenetic dissection of the Drosophila lateral horn reveals major outputs, diverse behavioural functions, and interactions with the mushroom body" =
    "M.-J. Dolan, S. Frechter, A. S. Bates, C. Dan, P. Huoviala, R. J. Roberts, P. Schlegel, S. Dhawan, R. Tabano, H. Dionne, C. Christoforou, K. Close, B. Sutcliffe, B. Giuliani, F. Li, M. Costa, G. Ihrke, G. W. Meissner, D. D. Bock, Y. Aso, G. M. Rubin, G. S. Jefferis",

  "Automated reconstruction of a serial-section EM Drosophila brain with flood-filling networks and local realignment" =
    "P. H. Li, L. F. Lindsey, M. Januszewski, Z. Zheng, A. S. Bates, I. Taisz, M. Tyka, M. Nichols, F. Li, E. Perlman, J. Ros, C. Bosch, M. Fetter, D. D. Bock, D. D. Bock, G. S. X. E. Jefferis, V. Jain",

  "Communication from learned to innate olfactory processing centers is required for memory retrieval in Drosophila" =
    "M.-J. Dolan, G. Belliart-Guérin, A. S. Bates, S. Frechter, A. Lampin-Saint-Amaux, Y. Aso, R. J. Roberts, P. Schlegel, A. Wong, A. Hammad, D. D. Bock, G. M. Rubin, T. Preat, P.-Y. Plaçais, G. S. X. E. Jefferis",

  "Neural circuit basis of aversive odour processing in Drosophila from sensory input to descending output" =
    "P. Huoviala, M.-J. Dolan, F. M. Love, P. Myers, S. Frechter, S. Namiki, A. S. Bates, R. J. Roberts, E. H. Crosetti, P. Schlegel, F. Li, G. M. Rubin, D. D. Bock, H. Tanimoto, G. S. X. E. Jefferis",

  "Connectome Influence Calculator" =
    "Z. Ajabi, A. S. Bates, J. Drugowitsch"
)

# Update author lists
for (title in names(full_authors)) {
  idx <- which(pub_data$title == title)
  if (length(idx) > 0) {
    pub_data$author[idx] <- full_authors[[title]]
  }
}

# Save with full author lists
write.csv(pub_data, "publications_full_citations.csv", row.names = FALSE)

cat("\nFull author lists added!\n")
cat("Papers with full author lists:", length(full_authors), "/", nrow(pub_data), "\n")
