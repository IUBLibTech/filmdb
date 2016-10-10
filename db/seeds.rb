# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# users
User.new(username: 'jaalbrec', first_name: 'Andrew', last_name: 'Albrecht', email_address: 'jaalbrec@indiana.edu', active: true).save
User.new(username: 'carton', first_name: 'Carla', last_name: 'Arton', email_address: 'carton@indiana.edu', active: true).save
User.new(username: 'jauhrich', first_name: 'Andy', last_name: 'Uhrich', email_address: 'jauhrich@indiana.edu', active: true).save
User.new(username: 'shmichae', first_name: 'Sherri', last_name: 'Michaels', email_address: 'shmichae@indiana.edu', active: true).save
User.new(username: 'wgcowan', first_name: 'Will', last_name: 'Cowan', email_address: 'wgcowan@indiana.edu', active: true).save
User.new(username: 'rstoeltj', first_name: 'Rachael', last_name: 'Stoeltje', email_address: 'rstoeltj@indiana.edu', active: true).save
User.new(username: 'aploshay', first_name: 'Adam', last_name: 'Ploshay', email_address: 'aploshay@iu.edu', active: true).save

# Units
Unit.new(abbreviation: 'B-AAAMC', name: "Indiana University, Bloomington. Archives of African American Music and Culture.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ALF', name: "Indiana University, Bloomington. Auxiliary Library Facility.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ARCHIVES', name: "Indiana University, Bloomington. Office of University Archives and Records Management.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATM', name: "Indiana University, Bloomington. Archives of Traditional Music.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-BCC', name: "Indiana University, Bloomington. Neal-Marshall Black Culture Center.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-BUSSPEA', name: "Indiana University, Bloomington. Business/SPEA Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CEDIR', name: "Indiana University, Bloomington. Indiana Institute on Disability and Community. Center for Disability Information & Referral.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CHEM', name: "Indiana University, Bloomington. Chemistry Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CYCLOTRN', name: "Indiana University, Bloomington. Cyclotron Facility.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-EDUC', name: "Indiana University, Bloomington. Education Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-FINEARTS', name: "Indiana University, Bloomington. Fine Arts Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-GEOLOGY', name: "Indiana University, Bloomington. Geology Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-HPER', name: "Indiana University, Bloomington. Public Health Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-KINSEY', name: "Indiana University, Bloomington. Kinsey Institute for Research in Sex, Gender, and Reproduction.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-LAW', name: "Indiana University, Bloomington. Law Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-LIFESCI', name: "Indiana University, Bloomington. Life Sciences Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-LILLY', name: "Indiana University, Bloomington. Lilly Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-MUSIC', name: "Indiana University, Bloomington. William and Gayle Cook Music Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-OPTOMTRY', name: "Indiana University, Bloomington. Optometry Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-SWAIN', name: "Indiana University, Bloomington. Swain Hall Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-WELLS', name: "Indiana University, Bloomington. Herman B Wells Library.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-AAAI', name: "Indiana University, Bloomington. African American Arts Institute.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ANTH', name: "Indiana University, Bloomington. Department of Anthropology.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ASTR', name: "Indiana University, Bloomington. Department of Astronomy.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-BFCA', name: "Indiana University, Bloomington. Black Film Center/Archives.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CSHM', name: "Indiana University, Bloomington. Center for the Study of History and Memory.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CEUS', name: "Indiana University, Bloomington. Department of Central Eurasian Studies.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-SAGE', name: "Indiana University, Bloomington. Elizabeth Sage Historic Costume Collection.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-IUAM', name: "Indiana University, Bloomington. Art Museum.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-MATHERS', name: "Indiana University, Bloomington. William Hammond Mathers Museum.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-MDP', name: "Indiana University, Bloomington. Media Design and Production.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-JOURSCHL', name: "Indiana University, Bloomington. School of Journalism.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-RTVS', name: "Indiana University, Bloomington. Radio and Television Services.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-GBL', name: "Indiana University, Bloomington. Glenn A. Black Laboratory of Archaeology.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-AFRIST', name: "Indiana University, Bloomington. African Studies Program.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-MUSBANDS', name: "Indiana University, Bloomington. Bands.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHBASKM', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Men's Basketball.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHBASKW', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Women's Basketball.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CELTIE', name: "Indiana Univeristy, Bloomington. Center for Language Technology and Instructional Enrichment.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CELCAR', name: "Indiana University, Bloomington. Center for Languages of the Central Asian Region.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CLACS', name: "Indiana University, Bloomington. Center for Latin American and Caribbean Studies.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CDEL', name: "Indiana University, Bloomington. Center for the Documentation of Endangered Languages.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CISAB', name: "Indiana University, Bloomington. Center for the Integrative Study of Animal Behavior.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-GLOBAL', name: "Indiana University, Bloomington. Center for the Study of Global Change.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CAC', name: "Indiana University, Bloomington. Center on Aging and Community.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CMCL', name: "Indiana University, Bloomington. Department of Communication and Culture.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-CREOLE', name: "Indiana University, Bloomington. Creole Institute.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-EASC', name: "Indiana University, Bloomington. East Asian Studies Center.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-EPPLEY', name: "Indiana University, Bloomington. Eppley Institute for Parks and Public Lands.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHFHOCKEY', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Field Hockey.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-FOLKETHNO', name: "Indiana University, Bloomington. Department of Folklore and Ethnomusicology.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHFTBL', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Football.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-GLBTSSSL', name: "Indiana University, Bloomington. Gay, Lesbian, Bisexual, Transgender Student Support Services Office.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-IPRC', name: "Indiana University, Bloomington. Indiana Prevention Resource Center.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-IAUNRC', name: "Indiana University, Bloomington. Inner Asian & Uralic National Resource Center.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-IAS', name: "Indiana University, Bloomington. Institute for Advanced Study.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-LACASA', name: "Indiana University, Bloomington. Latino Cultural Center.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-LIBERIA', name: "Indiana University, Bloomington. Liberian Collections.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-LING', name: "Indiana University, Bloomington. Linguistics Club.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-OPTMSCHL', name: "Indiana University, Bloomington. School of Optometry.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-POLISH', name: "Indiana University, Bloomington. Polish Studies Center.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-PSYCH', name: "Indiana University, Bloomington. Department of Psychological and Brain Sciences.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-MUSREC', name: "Indiana University, Bloomington. School of Music.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHROWING', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Rowing.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-REEI', name: "Indiana University, Bloomington. Russian and East European Institute.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHSOCCM', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Men's Soccer.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHSOFTB', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Softball.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-SAVAIL', name: "Indiana University, Bloomington. Sound and Video Analysis & Instruction Laboratory.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHTENNM', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Men's Tennis.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-THTR', name: "Indiana University, Bloomington. Department of Theatre and Drama.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-TAI', name: "Indiana University, Bloomington. Traditional Arts Indiana.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-GLEIM', name: "Indiana University, Bloomington. Unclaimed Collection #1. Chester Gleim.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-FRANKLIN', name: "Indiana University, Bloomington. Unclaimed Collection #2. Franklin Hall Attic.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-UNIVCOMM', name: "Indiana University, Bloomington. Office of Communications and Marketing.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHVIDEO', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Video Production.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-ATHVOLLW', name: "Indiana University, Bloomington. Department of Intercollegiate Athletics. Women's Volleyball.", institution: "Indiana University", campus: "Bloomington").save
Unit.new(abbreviation: 'B-WEST', name: "Indiana University, Bloomington. West European Studies Film Library.", institution: "Indiana University", campus: "Bloomington").save

# seed misc collections for each
Unit.all.each do |u|
  if u.misc_collection.nil?
    Collection.new(name: 'Misc [not in collection]', unit: u).save
  end
end