# Create clients
puts "Creating clients..."
clients = [
  { name: "TechCorp Inc.", company: "TechCorp", email: "hr@techcorp.com" },
  { name: "HealthCare Solutions", company: "HealthCare", email: "jobs@healthcare.com" },
  { name: "FinTech Innovations", company: "FinTech", email: "careers@fintech.com" }
]

clients.each do |client_attrs|
  Client.find_or_create_by!(email: client_attrs[:email]) do |client|
    client.assign_attributes(client_attrs)
  end
end

# Create job seekers
puts "Creating job seekers..."
job_seekers = [
  { name: "John Doe", email: "john@example.com", skills: "Ruby, Rails, JavaScript" },
  { name: "Jane Smith", email: "jane@example.com", skills: "Python, Django, React" },
  { name: "Alice Johnson", email: "alice@example.com", skills: "Java, Spring, Angular" }
]

job_seekers.each do |seeker_attrs|
  JobSeeker.find_or_create_by!(email: seeker_attrs[:email]) do |seeker|
    seeker.assign_attributes(seeker_attrs)
  end
end

# Create opportunities
puts "Creating opportunities..."
opportunities = [
  { 
    title: "Senior Rails Developer", 
    description: "Looking for an experienced Rails developer to join our team.", 
    salary: 120000.00, 
    client: Client.find_by(company: "TechCorp") 
  },
  { 
    title: "Healthcare Data Scientist", 
    description: "Join our team to analyze healthcare data and improve patient outcomes.", 
    salary: 110000.00, 
    client: Client.find_by(company: "HealthCare") 
  },
  { 
    title: "FinTech Software Engineer", 
    description: "Develop cutting-edge financial technology solutions.", 
    salary: 130000.00, 
    client: Client.find_by(company: "FinTech") 
  },
  { 
    title: "Junior Rails Developer", 
    description: "Great opportunity for a junior developer to learn and grow.", 
    salary: 75000.00, 
    client: Client.find_by(company: "TechCorp") 
  },
  { 
    title: "Full Stack Developer", 
    description: "Work on both frontend and backend for our healthcare platform.", 
    salary: 100000.00, 
    client: Client.find_by(company: "HealthCare") 
  }
]

opportunities.each do |opp_attrs|
  Opportunity.find_or_create_by!(title: opp_attrs[:title], client: opp_attrs[:client]) do |opp|
    opp.assign_attributes(opp_attrs)
  end
end

puts "Creating job applications..."
# Create some job applications
applications = [
  {
    job_seeker: JobSeeker.find_by(name: "John Doe"),
    opportunity: Opportunity.find_by(title: "Senior Rails Developer"),
    status: "pending"
  },
  {
    job_seeker: JobSeeker.find_by(name: "Jane Smith"),
    opportunity: Opportunity.find_by(title: "Healthcare Data Scientist"),
    status: "approved"
  },
  {
    job_seeker: JobSeeker.find_by(name: "Alice Johnson"),
    opportunity: Opportunity.find_by(title: "FinTech Software Engineer"),
    status: "pending"
  }
]

applications.each do |app_attrs|
  JobApplication.find_or_create_by!(
    job_seeker: app_attrs[:job_seeker],
    opportunity: app_attrs[:opportunity]
  ) do |app|
    app.status = app_attrs[:status]
  end
end

puts "Seed data created successfully!"
