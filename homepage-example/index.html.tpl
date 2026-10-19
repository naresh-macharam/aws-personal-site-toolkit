<!DOCTYPE html>
<!--
  STARTING TEMPLATE — sections still needing your real content:
  - Hero headline, bio, and stats (search "Your headline", "Your one-paragraph bio")
  - About: origin story, certifications, personal detail
  - Portfolio: swap the 3 example projects for your real ones
  - Services: edit the bullet list to match what you actually offer
  - Contact: social links (GitHub/LinkedIn/X) and the CONTACT_ENDPOINT
    in the <script> block near the bottom (comes from the contact-pipeline
    module's `contact_endpoint` output)
  - Resume link: point at your real hosted PDF
-->
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Your Name — Your Title</title>
<meta name="description" content="Cloud architecture and DevOps engineer specializing in secure, scalable AWS infrastructure, CI/CD pipelines, and observability.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
  :root{
    --bg: ${color_bg};
    --surface: ${color_surface};
    --surface-2: ${color_surface2};
    --border: ${color_border};
    --border-soft: ${color_border_soft};
    --ink: ${color_ink};
    --ink-dim: ${color_ink_dim};
    --ink-faint: ${color_ink_faint};
    --accent: ${color_accent};
    --accent-dim: ${color_accent_dim};
    --accent-ink: #06120E;
    --amber: #E8B25C;
    --radius: 3px;
    --wrap: 1180px;
    --font-display: 'Space Grotesk', 'Inter', sans-serif;
    --font-body: 'Inter', sans-serif;
    --font-mono: 'JetBrains Mono', monospace;
  }

  *{ margin:0; padding:0; box-sizing:border-box; }
  html{ scroll-behavior:smooth; }
  body{
    background:var(--bg);
    color:var(--ink);
    font-family:var(--font-body);
    line-height:1.6;
    -webkit-font-smoothing:antialiased;
    overflow-x:hidden;
  }
  body::before{
    content:'';
    position:fixed; inset:0;
    background-image:
      linear-gradient(var(--border-soft) 1px, transparent 1px),
      linear-gradient(90deg, var(--border-soft) 1px, transparent 1px);
    background-size:64px 64px;
    opacity:.35;
    pointer-events:none;
    z-index:0;
    mask-image: radial-gradient(ellipse 80% 60% at 50% 0%, black 20%, transparent 75%);
  }
  a{ color:inherit; text-decoration:none; }
  ul{ list-style:none; }
  img,svg{ display:block; max-width:100%; }
  section{ position:relative; z-index:1; }

  .wrap{ max-width:var(--wrap); margin:0 auto; padding:0 32px; }
  @media (max-width:640px){ .wrap{ padding:0 20px; } }

  .eyebrow{
    font-family:var(--font-mono);
    font-size:12.5px;
    letter-spacing:.04em;
    color:var(--accent);
    display:flex;
    align-items:center;
    gap:10px;
    margin-bottom:22px;
  }
  .eyebrow::before{
    content:'';
    width:7px; height:7px;
    border-radius:50%;
    background:var(--accent);
    box-shadow:0 0 0 3px var(--accent-dim);
  }

  h1,h2,h3{ font-family:var(--font-display); font-weight:600; letter-spacing:-0.01em; color:var(--ink); }

  :focus-visible{ outline:2px solid var(--accent); outline-offset:3px; }

  /* ---------- Header ---------- */
  header{
    position:fixed; top:0; left:0; right:0; z-index:50;
    background:rgba(11,15,20,.82);
    backdrop-filter:blur(10px);
    border-bottom:1px solid var(--border-soft);
  }
  .nav{
    display:flex; align-items:center; justify-content:space-between;
    height:68px;
  }
  .logo{
    font-family:var(--font-mono);
    font-size:15px; font-weight:500;
    color:var(--ink);
    display:flex; align-items:center; gap:9px;
  }
  .logo .dot{ width:8px; height:8px; border-radius:50%; background:var(--accent); box-shadow:0 0 8px var(--accent); }
  .logo .path{ color:var(--ink-faint); }
  .nav-links{ display:flex; gap:36px; }
  .nav-links a{
    font-size:14px; color:var(--ink-dim);
    transition:color .15s ease;
    position:relative;
  }
  .nav-links a:hover{ color:var(--ink); }
  .nav-cta{
    font-family:var(--font-mono);
    font-size:13px;
    color:var(--bg);
    background:var(--accent);
    padding:9px 18px;
    border-radius:var(--radius);
    font-weight:500;
  }
  .nav-toggle{ display:none; background:none; border:1px solid var(--border); color:var(--ink); width:38px; height:38px; border-radius:var(--radius); cursor:pointer; }
  @media (max-width:860px){
    .nav-links{
      position:fixed; top:68px; left:0; right:0;
      background:var(--surface);
      border-bottom:1px solid var(--border-soft);
      flex-direction:column; gap:0;
      max-height:0; overflow:hidden;
      transition:max-height .25s ease;
    }
    .nav-links.open{ max-height:340px; }
    .nav-links a{ padding:16px 24px; border-top:1px solid var(--border-soft); width:100%; }
    .nav-cta{ display:none; }
    .nav-toggle{ display:block; }
  }

  /* ---------- Hero ---------- */
  .hero{
    padding:160px 0 100px;
    display:grid;
    grid-template-columns:1.05fr .95fr;
    gap:56px;
    align-items:center;
  }
  @media (max-width:960px){ .hero{ grid-template-columns:1fr; padding:140px 0 60px; gap:64px; } }

  .hero h1{
    font-size:clamp(2.3rem, 4.6vw, 3.6rem);
    line-height:1.08;
    margin-bottom:24px;
  }
  .hero h1 em{
    font-style:normal;
    color:var(--accent);
  }
  .hero p.lead{
    font-size:17px;
    color:var(--ink-dim);
    max-width:52ch;
    margin-bottom:36px;
  }
  .cta-row{ display:flex; gap:14px; flex-wrap:wrap; margin-bottom:40px; }
  .btn{
    font-family:var(--font-mono);
    font-size:13.5px;
    padding:13px 24px;
    border-radius:var(--radius);
    display:inline-flex; align-items:center; gap:10px;
    transition:all .15s ease;
    border:1px solid transparent;
  }
  .btn-primary{ background:var(--ink); color:var(--bg); font-weight:500; }
  .btn-primary:hover{ background:var(--accent); }
  .btn-outline{ border-color:var(--border); color:var(--ink); }
  .btn-outline:hover{ border-color:var(--accent); color:var(--accent); }

  .meta-row{ display:flex; gap:28px; flex-wrap:wrap; }
  .meta-item{ font-family:var(--font-mono); font-size:12.5px; color:var(--ink-faint); }
  .meta-item b{ color:var(--ink-dim); font-weight:500; }

  /* ---------- Signature: infra graph ---------- */
  .graph-card{
    background:var(--surface);
    border:1px solid var(--border);
    border-radius:6px;
    padding:20px 20px 14px;
  }
  .graph-head{
    display:flex; justify-content:space-between; align-items:center;
    font-family:var(--font-mono); font-size:11.5px; color:var(--ink-faint);
    margin-bottom:10px; padding-bottom:14px; border-bottom:1px solid var(--border-soft);
  }
  .graph-head .live{ color:var(--accent); display:flex; align-items:center; gap:6px; }
  .graph-head .live::before{ content:''; width:6px; height:6px; border-radius:50%; background:var(--accent); animation:blip 1.6s ease-in-out infinite; }
  @keyframes blip{ 0%,100%%{ opacity:1; } 50%%{ opacity:.25; } }

  .node{ fill:var(--surface-2); stroke:var(--border); stroke-width:1; }
  .node-active{ stroke:var(--accent); }
  .node-label{ font-family:'JetBrains Mono',monospace; font-size:10px; fill:var(--ink-dim); }
  .edge{ stroke:var(--border); stroke-width:1.3; fill:none; }
  .edge-flow{ stroke:var(--accent); stroke-width:1.3; fill:none; stroke-dasharray:5 7; animation:flow 2.6s linear infinite; opacity:.9; }
  @keyframes flow{ to{ stroke-dashoffset:-120; } }
  .pulse{ fill:var(--accent); }

  @media (prefers-reduced-motion: reduce){
    .edge-flow{ animation:none; }
    .graph-head .live::before{ animation:none; }
  }

  /* ---------- Section shared ---------- */
  .section{ padding:110px 0; border-top:1px solid var(--border-soft); }
  .section-head{ max-width:640px; margin-bottom:56px; }
  .section-head h2{ font-size:clamp(1.7rem,3vw,2.3rem); }
  .section-head p{ color:var(--ink-dim); margin-top:14px; font-size:15.5px; }

  /* ---------- About ---------- */
  .about-grid{ display:grid; grid-template-columns:1.2fr .8fr; gap:64px; }
  @media (max-width:900px){ .about-grid{ grid-template-columns:1fr; gap:44px; } }
  .about-copy p{ color:var(--ink-dim); margin-bottom:18px; font-size:15.5px; max-width:60ch; }
  .about-copy .humanize{
    margin-top:28px; padding:16px 18px;
    border-left:2px solid var(--accent);
    background:var(--surface);
    font-size:14.5px; color:var(--ink-dim);
    font-style:normal;
  }

  .cert-list{ display:flex; flex-direction:column; gap:0; border:1px solid var(--border); border-radius:6px; overflow:hidden; }
  .cert-item{
    display:flex; justify-content:space-between; align-items:center;
    padding:16px 18px; border-bottom:1px solid var(--border-soft);
    font-size:14px;
  }
  .cert-item:last-child{ border-bottom:none; }
  .cert-item span:first-child{ color:var(--ink); }
  .cert-item span.tag{ font-family:var(--font-mono); font-size:11px; color:var(--accent); background:var(--accent-dim); padding:4px 8px; border-radius:2px; }

  /* ---------- Projects ---------- */
  .proj-grid{ display:grid; grid-template-columns:repeat(3,1fr); gap:24px; }
  @media (max-width:960px){ .proj-grid{ grid-template-columns:1fr; } }
  .proj-card{
    border:1px solid var(--border); border-radius:6px; background:var(--surface);
    padding:26px 24px; display:flex; flex-direction:column; height:100%;
    transition:border-color .15s ease, transform .15s ease;
  }
  .proj-card:hover{ border-color:var(--accent-dim); transform:translateY(-3px); }
  .proj-num{ font-family:var(--font-mono); font-size:11.5px; color:var(--ink-faint); margin-bottom:18px; }
  .proj-card h3{ font-size:18px; margin-bottom:10px; }
  .proj-card p{ font-size:14px; color:var(--ink-dim); margin-bottom:20px; flex-grow:1; }
  .stack-row{ display:flex; flex-wrap:wrap; gap:7px; margin-bottom:22px; }
  .stack-tag{ font-family:var(--font-mono); font-size:10.5px; color:var(--ink-dim); border:1px solid var(--border); padding:4px 9px; border-radius:2px; }
  .proj-links{ display:flex; gap:18px; font-family:var(--font-mono); font-size:12.5px; border-top:1px solid var(--border-soft); padding-top:16px; }
  .proj-links a{ color:var(--ink-dim); display:flex; align-items:center; gap:6px; }
  .proj-links a:hover{ color:var(--accent); }

  /* ---------- Services ---------- */
  .services-grid{ display:grid; grid-template-columns:repeat(2,1fr); gap:1px; background:var(--border-soft); border:1px solid var(--border-soft); border-radius:6px; overflow:hidden; }
  @media (max-width:760px){ .services-grid{ grid-template-columns:1fr; } }
  .service-item{ background:var(--bg); padding:30px 28px; }
  .service-item h3{ font-size:16px; margin-bottom:10px; display:flex; align-items:center; gap:10px; }
  .service-item h3::before{ content:'▸'; color:var(--accent); font-size:14px; }
  .service-item p{ font-size:14px; color:var(--ink-dim); }

  /* ---------- Contact ---------- */
  .contact-grid{ display:grid; grid-template-columns:1fr 1fr; gap:64px; }
  @media (max-width:900px){ .contact-grid{ grid-template-columns:1fr; gap:44px; } }
  .field{ margin-bottom:20px; }
  .field label{ display:block; font-family:var(--font-mono); font-size:12px; color:var(--ink-faint); margin-bottom:8px; }
  .field input, .field textarea{
    width:100%; background:var(--surface); border:1px solid var(--border);
    color:var(--ink); padding:12px 14px; border-radius:var(--radius);
    font-family:var(--font-body); font-size:14px;
  }
  .field input:focus, .field textarea:focus{ border-color:var(--accent); outline:none; }
  .field textarea{ min-height:120px; resize:vertical; }
  .submit-note{ font-size:12.5px; color:var(--ink-faint); margin-top:8px; }

  .social-col h3{ font-size:14px; color:var(--ink-dim); font-family:var(--font-mono); font-weight:400; margin-bottom:20px; }
  .social-list{ border:1px solid var(--border); border-radius:6px; overflow:hidden; }
  .social-list a{
    display:flex; justify-content:space-between; align-items:center;
    padding:16px 18px; border-bottom:1px solid var(--border-soft);
    font-size:14.5px; transition:background .15s ease;
  }
  .social-list a:last-child{ border-bottom:none; }
  .social-list a:hover{ background:var(--surface); color:var(--accent); }
  .social-list a span.arrow{ font-family:var(--font-mono); color:var(--ink-faint); }

  footer{ border-top:1px solid var(--border-soft); padding:32px 0; }
  .footer-row{ display:flex; justify-content:space-between; align-items:center; font-family:var(--font-mono); font-size:12px; color:var(--ink-faint); flex-wrap:wrap; gap:12px; }
</style>
</head>
<body>

<header>
  <nav class="nav wrap">
    <div class="logo"><span class="dot"></span>yourname<span class="path">/site</span></div>
    <ul class="nav-links" id="navLinks">
      <li><a href="#about">About</a></li>
      <li><a href="#work">Work</a></li>
      <li><a href="/blog/">Blog</a></li>
      <li><a href="#services">Services</a></li>
      <li><a href="#contact">Contact</a></li>
    </ul>
    <a href="#contact" class="nav-cta">Contact Me</a>
    <button class="nav-toggle" id="navToggle" aria-label="Toggle menu" aria-expanded="false">☰</button>
  </nav>
</header>

<main>
  <!-- HERO -->
  <section class="hero wrap" id="hero">
    <div>
      <p class="eyebrow">~/whoami</p>
      <h1>Your headline goes <em>here</em>.</h1>
      <p class="lead">Your one-paragraph bio goes here — what you do, what you specialize in, what makes you worth a second look.</p>
      <div class="cta-row">
        <a href="/Naresh-Macharam-Resume.pdf" target="_blank" rel="noopener" class="btn btn-primary">View Resume →</a>
        <a href="#contact" class="btn btn-outline">Contact Me</a>
      </div>
      <div class="meta-row">
        <span class="meta-item"><b>X yrs</b> your specialty</span>
        <span class="meta-item"><b>X yrs</b> prior role</span>
        <span class="meta-item"><b>Based in</b> Your City</span>
      </div>
    </div>

    <div class="graph-card">
      <div class="graph-head">
        <span>infra_map.svg</span>
        <span class="live">operational</span>
      </div>
      <svg viewBox="0 0 420 320" width="100%" role="img" aria-label="Diagram of a cloud infrastructure pipeline connecting version control, CI/CD, Kubernetes, monitoring, and storage">
        <!-- edges -->
        <path class="edge" d="M70,60 L200,60" />
        <path class="edge-flow" d="M70,60 L200,60" />
        <path class="edge" d="M200,60 L200,150" />
        <path class="edge-flow" d="M200,60 L200,150" style="animation-delay:.3s" />
        <path class="edge" d="M200,150 L90,220" />
        <path class="edge-flow" d="M200,150 L90,220" style="animation-delay:.6s" />
        <path class="edge" d="M200,150 L310,220" />
        <path class="edge-flow" d="M200,150 L310,220" style="animation-delay:.9s" />
        <path class="edge" d="M200,150 L200,260" />
        <path class="edge-flow" d="M200,150 L200,260" style="animation-delay:1.2s" />

        <!-- nodes -->
        <g>
          <rect class="node" x="35" y="42" width="70" height="36" rx="3"/>
          <text class="node-label" x="70" y="64" text-anchor="middle">git push</text>
        </g>
        <g>
          <rect class="node node-active" x="163" y="42" width="74" height="36" rx="3"/>
          <text class="node-label" x="200" y="64" text-anchor="middle">CI / Jenkins</text>
        </g>
        <g>
          <rect class="node node-active" x="160" y="132" width="80" height="36" rx="3"/>
          <text class="node-label" x="200" y="154" text-anchor="middle">EKS cluster</text>
        </g>
        <g>
          <rect class="node" x="52" y="202" width="76" height="36" rx="3"/>
          <text class="node-label" x="90" y="224" text-anchor="middle">Terraform</text>
        </g>
        <g>
          <rect class="node" x="272" y="202" width="76" height="36" rx="3"/>
          <text class="node-label" x="310" y="224" text-anchor="middle">Prometheus</text>
        </g>
        <g>
          <rect class="node" x="162" y="242" width="76" height="36" rx="3"/>
          <text class="node-label" x="200" y="264" text-anchor="middle">S3 / RDS</text>
        </g>

        <circle class="pulse" cx="70" cy="60" r="3"><animate attributeName="opacity" values="1;0.2;1" dur="1.8s" repeatCount="indefinite"/></circle>
      </svg>
    </div>
  </section>

  <!-- ABOUT -->
  <section class="section" id="about">
    <div class="wrap">
      <div class="about-grid">
        <div>
          <p class="eyebrow">~/about</p>
          <h2 style="margin-bottom:28px;">From data pipelines to cloud platforms</h2>
          <div class="about-copy">
            <p>I started my career as a Data Engineer at TCS, spending two years moving data reliably through Talend pipelines into Redshift and building the Tableau dashboards that leadership actually opened. That work taught me a lesson that shaped everything after: a system is only as trustworthy as its weakest handoff.</p>
            <p>That's what pulled me toward infrastructure. For the past three years I've focused on cloud architecture — designing AWS environments, writing Terraform that other engineers can read, and building CI/CD pipelines that fail loudly instead of silently. I care about systems that are boring in the best way: predictable, observable, and easy to hand off.</p>
            <p>Today I work across AWS, Kubernetes, Jenkins, and GitHub Actions, with Prometheus and Grafana watching everything I ship.</p>
            <p class="humanize">Off the clock, I'm usually deep in a Stoic philosophy book or arguing that a well-run infrastructure and a well-run life follow the same principle — control what you can, monitor the rest.</p>
          </div>
        </div>

        <div>
          <ul class="cert-list">
            <li class="cert-item"><span>AWS Solutions Architect – Professional</span><span class="tag">AWS</span></li>
            <li class="cert-item"><span>AWS DevOps Engineer – Professional</span><span class="tag">AWS</span></li>
            <li class="cert-item"><span>HashiCorp Certified: Terraform Associate</span><span class="tag">IaC</span></li>
            <li class="cert-item"><span>Certified Kubernetes Administrator (CKA)</span><span class="tag">K8s</span></li>
          </ul>
        </div>
      </div>
    </div>
  </section>

  <!-- PROJECTS -->
  <section class="section" id="work">
    <div class="wrap">
      <div class="section-head">
        <p class="eyebrow">~/projects</p>
        <h2>Selected work</h2>
        <p>A few systems I've designed and shipped, end to end — from architecture decisions to the pipelines that keep them running.</p>
      </div>

      <div class="proj-grid">
        <div class="proj-card">
          <div class="proj-num">01 / infrastructure</div>
          <h3>Multi-environment AWS platform on EKS</h3>
          <p>Designed and provisioned a production-grade EKS platform across dev, staging, and prod using modular Terraform. Cut environment provisioning time from days to under an hour and eliminated manual console changes entirely.</p>
          <div class="stack-row">
            <span class="stack-tag">AWS</span>
            <span class="stack-tag">Terraform</span>
            <span class="stack-tag">EKS</span>
            <span class="stack-tag">IAM</span>
          </div>
          <div class="proj-links">
            <a href="#">GitHub ↗</a>
            <a href="#">Case study ↗</a>
          </div>
        </div>

        <div class="proj-card">
          <div class="proj-num">02 / automation</div>
          <h3>Zero-downtime CI/CD pipeline</h3>
          <p>Built a Jenkins and GitHub Actions pipeline with automated testing gates and blue-green deployment to Kubernetes, replacing a manual release process that used to take a full afternoon.</p>
          <div class="stack-row">
            <span class="stack-tag">Jenkins</span>
            <span class="stack-tag">GitHub Actions</span>
            <span class="stack-tag">Kubernetes</span>
            <span class="stack-tag">Python</span>
          </div>
          <div class="proj-links">
            <a href="#">GitHub ↗</a>
            <a href="#">Live demo ↗</a>
          </div>
        </div>

        <div class="proj-card">
          <div class="proj-num">03 / observability</div>
          <h3>Real-time infrastructure KPI dashboard</h3>
          <p>Instrumented services with Prometheus and built Grafana dashboards tracking latency, error rate, and cost per environment — giving engineering leads a single view instead of five disconnected tools.</p>
          <div class="stack-row">
            <span class="stack-tag">Prometheus</span>
            <span class="stack-tag">Grafana</span>
            <span class="stack-tag">AWS CloudWatch</span>
          </div>
          <div class="proj-links">
            <a href="#">GitHub ↗</a>
            <a href="#">Case study ↗</a>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- SERVICES -->
  <section class="section" id="services">
    <div class="wrap">
      <div class="section-head">
        <p class="eyebrow">~/services</p>
        <h2>How I can help</h2>
        <p>Available for consulting engagements and freelance builds, from a single pipeline to a full platform.</p>
      </div>

      <div class="services-grid">
        <div class="service-item">
          <h3>Cloud infrastructure setup</h3>
          <p>Architecture design and provisioning for new or growing environments, built to scale without rework.</p>
        </div>
        <div class="service-item">
          <h3>AWS setup &amp; hardening</h3>
          <p>Account structure, IAM policy, networking, and cost controls set up the way AWS actually recommends.</p>
        </div>
        <div class="service-item">
          <h3>CI/CD pipeline building</h3>
          <p>Automated build, test, and deployment pipelines with Jenkins, GitHub Actions, or your tool of choice.</p>
        </div>
        <div class="service-item">
          <h3>KPI &amp; monitoring dashboards</h3>
          <p>Prometheus and Grafana setups that surface the metrics your team actually needs to act on.</p>
        </div>
        <div class="service-item">
          <h3>Infrastructure as Code migration</h3>
          <p>Moving manually managed infrastructure into version-controlled Terraform, safely and incrementally.</p>
        </div>
        <div class="service-item">
          <h3>Kubernetes cluster management</h3>
          <p>EKS cluster setup, workload configuration, and ongoing operational support.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- CONTACT -->
  <section class="section" id="contact">
    <div class="wrap">
      <div class="section-head">
        <p class="eyebrow">~/contact</p>
        <h2>Let's talk infrastructure</h2>
        <p>Open to full-time roles, contract work, and short consulting engagements. Based in Hyderabad, working with teams anywhere.</p>
      </div>

      <div class="contact-grid">
        <form id="contact-form">
          <div style="position:absolute; left:-9999px; width:1px; height:1px; overflow:hidden;" aria-hidden="true">
            <label for="website">Leave this field empty</label>
            <input type="text" id="website" name="website" tabindex="-1" autocomplete="off">
          </div>
          <div class="field">
            <label for="name">Name</label>
            <input id="name" name="name" type="text" placeholder="Your name" required>
          </div>
          <div class="field">
            <label for="email">Email</label>
            <input id="email" name="email" type="email" placeholder="you@company.com" required>
          </div>
          <div class="field">
            <label for="message">Message</label>
            <textarea id="message" name="message" placeholder="What are you looking to build?" required></textarea>
          </div>
          <button type="submit" class="btn btn-primary" style="border:none; cursor:pointer;">Send Message →</button>
          <p class="submit-note" id="contact-status"></p>
        </form>

        <div class="social-col">
          <h3>Find me elsewhere</h3>
          <div class="social-list">
            <a href="#" target="_blank" rel="noopener">GitHub <span class="arrow">↗</span></a>
            <a href="#" target="_blank" rel="noopener">LinkedIn <span class="arrow">↗</span></a>
            <a href="#" target="_blank" rel="noopener">X / Twitter <span class="arrow">↗</span></a>
            <a href="mailto:you@example.com">Email <span class="arrow">↗</span></a>
          </div>
        </div>
      </div>
    </div>
  </section>
</main>

<footer>
  <div class="wrap footer-row">
    <span>© 2026 Your Name</span>
    <span>Built with Terraform-grade attention to detail</span>
  </div>
</footer>

<meta id="site-config" data-contact-endpoint="${contact_endpoint}">

<script>
  const navToggle = document.getElementById('navToggle');
  const navLinks = document.getElementById('navLinks');
  navToggle.addEventListener('click', () => {
    const isOpen = navLinks.classList.toggle('open');
    navToggle.setAttribute('aria-expanded', isOpen);
  });
  navLinks.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
    navLinks.classList.remove('open');
    navToggle.setAttribute('aria-expanded', 'false');
  }));

  // Contact form submission
  const config = document.getElementById('site-config');
  const CONTACT_ENDPOINT = config.dataset.contactEndpoint;
  const contactForm = document.getElementById('contact-form');
  const contactStatus = document.getElementById('contact-status');

  if (contactForm) {
    contactForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const submitBtn = contactForm.querySelector('button[type="submit"]');
      submitBtn.disabled = true;
      contactStatus.textContent = 'Sending…';

      const payload = {
        name: contactForm.name.value,
        email: contactForm.email.value,
        message: contactForm.message.value,
        website: contactForm.website.value,
        source: 'contact form'
      };

      try {
        const res = await fetch(CONTACT_ENDPOINT, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        if (res.ok) {
          contactStatus.textContent = 'Message sent — thanks, I\'ll get back to you soon.';
          contactForm.reset();
        } else {
          contactStatus.textContent = 'Something went wrong. Please try again or email me directly.';
        }
      } catch (err) {
        contactStatus.textContent = 'Something went wrong. Please try again or email me directly.';
      } finally {
        submitBtn.disabled = false;
      }
    });
  }
</script>

</body>
</html>
