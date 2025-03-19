# INTERVIEW

---

# **Wolf - Ruby on Rails Staff Engineer Technical Assessment**

**Duration:** 3 - 4 hours

**Format:** Submit code via GitHub (or similar) with README explaining decisions.

---

## **1. Algorithmic Challenge: Rate Limiter (Leetcode Medium-Hard Level)**

**Problem Statement:**

Your task is to **implement a rate limiter** for API requests in Ruby. Given a stream of incoming API requests in the form of:

```ruby
[
  { timestamp: 1700000010, user_id: 1 },
  { timestamp: 1700000011, user_id: 2 },
  { timestamp: 1700000020, user_id: 1 },
  { timestamp: 1700000035, user_id: 1 },
  { timestamp: 1700000040, user_id: 1 }
]

```

Each **user_id** is allowed a maximum of **3 requests per 30 seconds**.

Write a Ruby class `RateLimiter` that implements:

```ruby
class RateLimiter
  def initialize(time_window, max_requests)
    # initialize your storage
  end

  def allow_request?(timestamp, user_id)
    # returns true if request is allowed, false otherwise
  end
end

```

### **Expectations:**

- **Efficient implementation** (O(1) or O(logN) operations)
- **Scalability** (Handle millions of users)
- Use a **sliding window approach** (not fixed window).
- Provide **test cases** using RSpec.

### **Evaluation Criteria:**

✔️ Correctness (Does it correctly allow/block requests?)

✔️ Performance (Does it scale well with high request volumes?)

✔️ Readability (Is the code clear and maintainable?)

---

## **2. Rails Deep-Dive: Job Marketplace API & Optimization**

**Problem Statement:**

You need to **build a small API for job seekers**. Implement the following in a Rails application:

### **Models**

### **Opportunity Model**

```ruby
class Opportunity < ApplicationRecord
  belongs_to :client
  has_many :applications
  validates :title, :description, :salary, presence: true
end

```

### **Client Model**

```ruby
class Client < ApplicationRecord
  has_many :opportunities
end

```

### **JobApplication Model**

```ruby
class JobApplication < ApplicationRecord
  belongs_to :job_seeker
  belongs_to :opportunity
end

```

### **Tasks**

1. **API Endpoints (CRUD)**
    - Implement `GET /opportunities` (with pagination & search)
    - Implement `POST /opportunities` (clients can create jobs)
    - Implement `POST /opportunities/:id/apply` (job seekers apply)
2. **Optimize N+1 Queries**
    - Fix N+1 problems when fetching `opportunities` with `client_name`.
3. **Background Job**
    - Use **Sidekiq** to send a notification when a job seeker applies.
4. **Performance**
    - Use **caching** (e.g., Redis fragment caching) to speed up opportunity search.
5. **Testing**
    - Provide RSpec tests for API endpoints.

### **Expectations:**

✔️ **Efficient Queries** (No N+1 problems, correct indexes)

✔️ **Modular Code** (Uses services for business logic, not controllers)

✔️ **Background Job** (Sidekiq usage)

✔️ **Good Test Coverage**
