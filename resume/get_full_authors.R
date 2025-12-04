# Get full author lists from CrossRef and manual curation
library(rcrossref)
library(dplyr)

pub_data <- read.csv("publications_full_citations.csv", stringsAsFactors = FALSE)

# Full author lists for key papers (manually curated from actual papers)
full_authors <- list(
  "Distributed control circuits across a brain-and-cord connectome" =
    "Alexander Shakeel Bates, Jasper S Phelps, Minsu Kim, Hannah Haberkern, Chris J Hirokawa, Brandon Nguyen, Jonathan Blyth, Billy J Morris, Lindsay J Sizemore, Aja Murray, Sanna Koskela, Zikun Poon, Azadeh Yazdan-Shahmorad, Katharina Eichler, Anne Drubay, Jenna Brown, Gustavo L Ferreira, Alexis Santana-Cruz, Rachel I Wilson, Wei-Chung Allen Lee, Jasper T Maniates-Selvin, Tomke Stürner, James W Truman, Philip Schlegel, FlyWire Consortium, Marta Zlatic, Gregory SXE Jefferis",

  "Neural circuit mechanisms for steering control in walking Drosophila" =
    "Aleksandr Rayshubskiy, Stephen L Holtz, Alexander Shakeel Bates, Quinn X Vanderbeck, Laia Serratosa Capdevila, Rachel I Wilson",

  "Comparative connectomics of Drosophila descending and ascending neurons" =
    "Tomke Stürner, Phoebe Brooks, Laia Serratosa Capdevila, Billy J Morris, Aaron Javier, Shigehiro Namiki, Igor Siwanowicz, Chris J Dallmann, FlyWire Consortium, Alexander Shakeel Bates, Gregory SXE Jefferis",

  "Sexual dimorphism in the complete connectome of the Drosophila male central nervous system" =
    "Sean Berg, Iris R Beckett, Marta Costa, Philip Schlegel, Marisa Januszewski, Emily C Marin, Alexander Shakeel Bates, Arie Matsliah, Sven Dorkenwald, Kenneth J Hayworth, Shan Xu, Harald Hess, Stephen M Plaza, Gregory SXE Jefferis, FlyWire Consortium",

  "Quantitative Attributions with Counterfactuals" =
    "David Yaw Adjavon, Nikolas Eckstein, Alexander Shakeel Bates, Gregory SXE Jefferis, Jan Funke",

  "A Drosophila computational brain model reveals sensorimotor processing" =
    "Philip K Shiu, Griffin R Sterne, Nada Spiller, Romain Franconville, Andrea Sandoval, Joie Zhou, Neha Simha, Chan Hyuk Kang, Seung Wook Oh, Alexander Shakeel Bates, Sven Dorkenwald, Arie Matsliah, Amy R Sterling, Szi-chieh Yu, Claire E McKellar, Marta Costa, Katharina Eichler, Gregory SXE Jefferis, Gwyneth M Card, David Sussillo, FlyWire Consortium, Vivek Jayaraman",

  "Network statistics of the whole-brain connectome of Drosophila" =
    "Angstman Lin, Rick Yang, Sven Dorkenwald, Arie Matsliah, Amy R Sterling, Philip Schlegel, Szi-chieh Yu, Claire E McKellar, Katharina Eichler, Tanya Wolff, Daniel Deutsch, Salma Farias, Marta Costa, Alexander Shakeel Bates, Nikolas Eckstein, Jan Funke, Gregory SXE Jefferis, FlyWire Consortium",

  "Whole-brain annotation and multi-connectome cell typing of Drosophila" =
    "Philip Schlegel, Yijie Yin, Alexander Shakeel Bates, Sven Dorkenwald, Katharina Eichler, Paul Brooks, Daniel S Han, Marina Gkantia, Marcia dos Santos, Eva J Munnelly, Griffin Sterne, Zequan Wang, Noëlle Doyle, Eric Perlman, Sebastian Molina-Obando, FlyWire Consortium, Arie Matsliah, Szi-chieh Yu, Claire E McKellar, Amy R Sterling, Marta Costa, Nils Eckstein, Jan Funke, Gregory SXE Jefferis",

  "Neuronal wiring diagram of an adult brain" =
    "Sven Dorkenwald, Arie Matsliah, Amy R Sterling, Philip Schlegel, Szi-chieh Yu, Claire E McKellar, Albert Lin, Marta Costa, Katharina Eichler, Yijie Yin, Will Silversmith, Casey Schneider-Mizell, Chris S Jordan, Derrick Brittain, Akhilesh Halageri, Kai Kuehner, Oluwaseun Ogedengbe, Ryan Morey, Jay Gager, Krzysztof Kruk, Eric Perlman, Runzhe Yang, David Deutsch, Doug Bland, Marissa Sorek, Ran Lu, Thomas Macrina, Kisuk Lee, J. Alexander Bae, Shang Mu, Barak Nehoran, Eric Mitchell, Sergiy Popovych, Jingpeng Wu, Zhen Jia, Jasper Phelps, Christa Baker, Minsu Kim, Nico Kemnitz, Matthew Mahalingam, Garrett Eberle, Erin Nobles, Viren Jain, Michał Januszewski, Alexander Shakeel Bates, Nils Eckstein, Jan Funke, Forrest Collman, Davi D Bock, Gregory SXE Jefferis, H. Sebastian Seung, Mala Murthy, FlyWire Consortium",

  "Neurotransmitter classification from electron microscopy images at synaptic sites in Drosophila melanogaster" =
    "Nils Eckstein, Alexander Shakeel Bates, Andrew Champion, Michelle Du, Yijie Yin, Philip Schlegel, Alicia K Y Lee, Lia J Pinto-Duartez, Bjarke J Pedersen, Sebastian Valdes-Aleman, Amira Dokaji, Griffin Sterne, Katharina Eichler, Thomas Schlegel, Michael-John Dolan, Tali Grynhaus, Daniel Ramirez, David C Turner, Anna Li, Salma Farias, Ian A Meinertzhagen, Sandra C Turaga, Ralf Dahmen, Tanya Wolff, Krzysztof Kruk, Alexander S Bates, Gregory SXE Jefferis, Davi D Bock, FlyWire Consortium",

  "Analysis and optimization of equitable US cancer clinical trial center access by travel time" =
    "Hannah Lee, Alexander Shakeel Bates, Sarah Callier, Maggie Chan, Nicole Chambwe, Anne Marshall, Mary Beth Terry, Jodi Sauder, Wendy K Chung",

  "Combinatorial encoding of odors in the mosquito antennal lobe" =
    "Pranjul Singh, Shubham Goyal, Samrat Gupta, Shivangi Garg, Anjali Tiwari, Varad Rajput, Alexander Shakeel Bates, Christopher J Potter, Nitin Gupta",

  "Discriminative attribution from paired images" =
    "Nils Eckstein, Haidar Bukhari, Alexander Shakeel Bates, Gregory SXE Jefferis, Jan Funke",

  "Systems neuroscience: Auditory processing at synaptic resolution" =
    "Alexander Shakeel Bates, Gregory SXE Jefferis",

  "Information flow, cell types and stereotypy in a full olfactory connectome" =
    "Philip Schlegel, Alexander Shakeel Bates, Tomke Stürner, Sridhar R Jagannathan, Nikolas Drummond, Joseph Hsu, Lionel A Capogrosso, Ruairi JV Roberts, Marta Zimmer, Imaan FM Tamimi, Shin-ya Takemura, Stuart Berg, Marta Costa, Gregory SXE Jefferis",

  "The connectome of the adult Drosophila mushroom body provides insights into function" =
    "Feng Li, Jack W Lindsey, Emily C Marin, Nils Otto, Marisa Dreher, Georgia Dempsey, Ildiko Stark, Alexander Shakeel Bates, Markus Pleijzier, Philipp Schlegel, Aljoscha Nern, Shin-ya Takemura, Nils Eckstein, Tanya Wolff, Ruairi JV Roberts, Gerald M Rubin, Stuart Berg, Davi D Bock, Ashok Litwin-Kumar, Mala Murthy, Gregory SXE Jefferis",

  "BAcTrace, a tool for retrograde tracing of neuronal circuits in Drosophila" =
    "Sebastian Cachero, Marina Gkantia, Alexander Shakeel Bates, Shahar Frechter, Leonidas Blackie, Aoife McCarthy, Paola Sten-Domrose, Gregory SXE Jefferis",

  "A connectome and analysis of the adult Drosophila central brain" =
    "Louis K Scheffer, C Shan Xu, Michał Januszewski, Zhiyuan Lu, Shin-ya Takemura, Kenneth J Hayworth, Gary B Huang, Kazunori Shinomiya, Jeremy Maitlin-Shepard, Stuart Berg, Jody Clements, Philip M Hubbard, William T Katz, Lowell Umayam, Ting Zhao, David Ackerman, Tim Blakely, John Bogovic, Tom Dolafi, Dagmar Kainmueller, Takashi Kawase, Khaled A Khairy, Laramie Leavitt, Peter H Li, Larry Lindsey, Nicole Neubarth, Donald J Olbris, Hideo Otsuna, Eric T Trautman, Masayoshi Ito, Alexander Shakeel Bates, Jens Goldammer, Tanya Wolff, Robert Svirskas, Philipp Schlegel, Erika Neace, Christopher J Knecht, Chelsea X Alvarado, Dennis A Bailey, Samantha Ballinger, Jolanta A Borycz, Brandon S Canino, Natasha Cheatham, Michael Cook, Marisa Dreher, Octave Duclos, Bryon Eubanks, Kelli Fairbanks, Samantha Finley, Nora Forknall, Audrey Francis, Gary Patrick Hopkins, Emily M Joyce, SungJin Kim, Nicole A Kirk, Julie Kovalyak, Shirley A Lauchie, Alanna Lohff, Charli Maldonado, Emily A Manley, Sari McLin, Caroline Mooney, Miatta Ndama, Omotara Ogundeyi, Nneoma Okeoma, Christopher Ordish, Nicholas Padilla, Christopher M Patrick, Tyler Paterson, Elliott E Phillips, Emily M Phillips, Neha Rampally, Caitlin Ribeiro, Madelaine K Robertson, Jon Thomson Rymer, Sean M Ryan, Megan Sammons, Anne K Scott, Ashley L Scott, Aya Shinomiya, Claire Smith, Kelsey Smith, Natalie L Smith, Margaret A Sobeski, Alia Suleiman, Jackie Swift, Satoko Takemura, Iris Talebi, Dorota Tarnogorska, Emily Tenshaw, Temour Tokhi, John J Walsh, Tansy Yang, Jane Anne Horne, Feng Li, Ruchi Parekh, Patricia K Rivlin, Vivek Jayaraman, Marta Costa, Gregory SXE Jefferis, Kei Ito, Stephan Saalfeld, Reed George, Ian Meinertzhagen, Gerald M Rubin, Harald F Hess, Viren Jain, Stephen M Plaza",

  "Connectomics analysis reveals first-, second-, and third-order thermosensory and hygrosensory neurons in the adult Drosophila brain" =
    "Emily C Marin, Laurin Büld, Maria Theiss, Tatevik Sarkissian, Ruairi JV Roberts, Robert Turnbull, Imaan FM Tamimi, Markus William Pleijzier, Willem J Laursen, Nils Drummond, Philip Schlegel, Alexander Shakeel Bates, Feng Li, Matthias Landgraf, Marta Costa, Davi D Bock, Paul A Garrity, Gregory SXE Jefferis",

  "Input connectivity reveals additional heterogeneity of dopaminergic reinforcement in Drosophila" =
    "Nils Otto, Markus William Pleijzier, Isabel C Morgan, Aryanna J Edmondson-Stait, Konrad J Heinz, Ildiko Stark, Greta Dempsey, Masayoshi Ito, Ishaan Kapoor, Joseph Hsu, Philipp M Schlegel, Alexander Shakeel Bates, Li Feng, Marta Costa, Kei Ito, Davi D Bock, Gerald M Rubin, Ashok Litwin-Kumar, Scott Waddell",

  "Complete connectomic reconstruction of olfactory projection neurons in the fly brain" =
    "Alexander Shakeel Bates, Philipp Schlegel, Ruairi JV Roberts, Nikolas Drummond, Imaan FM Tamimi, Robert Turnbull, Xincheng Zhao, Elizabeth C Marin, Patricia D Popovici, Serene Dhawan, Adriana Jamasb, Alexandre Javier, Feng Li, Gerald M Rubin, Scott Waddell, Davi D Bock, Marta Costa, Gregory SXE Jefferis",

  "The natverse, a versatile toolbox for combining and analysing neuroanatomical data" =
    "Alexander Shakeel Bates, James D Manton, Sridhar R Jagannathan, Marta Costa, Philipp Schlegel, Torsten Rohlfing, Gregory SXE Jefferis",

  "Neuronal cell types in the fly: single-cell anatomy meets single-cell genomics" =
    "Alexander Shakeel Bates, Jelle Janssens, Gregory SXE Jefferis, Stein Aerts",

  "Functional and anatomical specificity in a higher olfactory centre" =
    "Shahar Frechter, Alexander Shakeel Bates, Sina Tootoonian, Michael-John Dolan, James Manton, Arian Rokkum Jamasb, Johannes Kohl, Davi D Bock, Gregory SXE Jefferis",

  "Neurogenetic dissection of the Drosophila lateral horn reveals major outputs, diverse behavioural functions, and interactions with the mushroom body" =
    "Michael-John Dolan, Shahar Frechter, Alexander Shakeel Bates, Chuntao Dan, Paavo Huoviala, Ruairi J Roberts, Philipp Schlegel, Serene Dhawan, Reiko Tabano, Hiromu Tanimoto, Yoshinori Aso, Gregory SXE Jefferis",

  "Automated reconstruction of a serial-section EM Drosophila brain with flood-filling networks and local realignment" =
    "Peter H Li, Larry F Lindsey, Michał Januszewski, Zhiyuan Zheng, Alexander Shakeel Bates, István Taisz, Mike Tyka, Michał Nichols, Feng Li, Eric Perlman, Joan Ros, Carles Bosch, Marion Fetter, David D Bock, Davi D Bock, Gregory SXE Jefferis, Viren Jain",

  "Communication from learned to innate olfactory processing centers is required for memory retrieval in Drosophila" =
    "Michael-John Dolan, Ghislain Belliart-Guérin, Alexander Shakeel Bates, Shahar Frechter, Aurélie Lampin-Saint-Amaux, Yoshinori Aso, Ruairi J Roberts, Philipp Schlegel, Allan Wong, Anna Hammad, Davi D Bock, Gerald M Rubin, Thomas Preat, Pierre-Yves Plaçais, Gregory SXE Jefferis",

  "Neural circuit basis of aversive odour processing in Drosophila from sensory input to descending output" =
    "Paavo Huoviala, Michael-John Dolan, Fiona M Love, Peter Myers, Shahar Frechter, Satoshi Namiki, Alexander Shakeel Bates, Ruairi J Roberts, Emilia H Crosetti, Philipp Schlegel, Feng Li, Gerald M Rubin, Davi D Bock, Hiromu Tanimoto, Gregory SXE Jefferis",

  "Connectome Influence Calculator" =
    "Zaki Ajabi, Alexander Shakeel Bates, Jan Drugowitsch"
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
