const services = [
  { number: "01", name: "Home Assistant deployment", price: "$50", cadence: "one time", description: "A clean, dependable Home Assistant setup built around the devices you already own.", features: ["Core installation", "Initial device pairing", "Secure local setup"], accent: "lime" },
  { number: "02", name: "Monitoring & management", price: "$10", cadence: "per month", description: "Lightweight oversight for your network or Home Assistant installation.", features: ["Choose network or HA", "Routine health checks", "Issue alerts"], accent: "blue" },
  { number: "03", name: "Remote assistance", price: "$20", cadence: "per month", description: "Straightforward remote help when a device, service, or network stops cooperating.", features: ["Remote troubleshooting", "Configuration help", "Priority scheduling"], accent: "orange" },
  { number: "04", name: "Remote + onsite", price: "$50", cadence: "per month", description: "Ongoing remote support with one onsite visit included every month.", features: ["Everything in remote", "1 onsite visit / month", "Preventive checkup"], accent: "violet", featured: true },
];

const steps = [
  ["Tell me what’s wrong", "Send a short note about your setup, your goal, or the problem you’re seeing."],
  ["Get a clear plan", "I’ll confirm the scope, price, and timing before any work begins."],
  ["Get it handled", "I’ll fix, configure, or monitor it—and explain what changed in plain English."],
];

const bookingHref = (service = "IT support") =>
  `mailto:hello@naturalcarr.com?subject=${encodeURIComponent(`Help with ${service}`)}&body=${encodeURIComponent("Hi Natural,\n\nI’m interested in this service. Here’s a little about what I need:\n\n")}`;

export default function Home() {
  return (
    <main>
      <nav className="nav shell" aria-label="Main navigation">
        <a className="brand" href="#top" aria-label="Natural Carr IT home"><span className="brand-mark">NC</span><span>Natural Carr</span></a>
        <div className="nav-links"><a href="#services">Services</a><a href="#process">How it works</a><a className="button button-small" href={bookingHref()}>Book a call <span aria-hidden="true">↗</span></a></div>
      </nav>

      <section className="hero shell" id="top">
        <div className="hero-copy">
          <div className="eyebrow"><span className="status-dot" /> Freelance IT support</div>
          <h1>Home tech,<br /><em>handled.</em></h1>
          <p className="hero-lede">Personal, practical help for smart homes, home networks, and the tech that keeps your household running.</p>
          <div className="hero-actions"><a className="button button-primary" href="#services">See services <span aria-hidden="true">↓</span></a><a className="text-link" href={bookingHref()}>Tell me what you need <span aria-hidden="true">↗</span></a></div>
          <div className="trust-row" aria-label="Service benefits"><span>Clear pricing</span><span>No jargon</span><span>Local support</span></div>
        </div>
        <div className="hero-console" aria-label="System status illustration">
          <div className="console-top"><span /><span /><span /><b>home.status</b></div>
          <div className="console-body">
            <p><span className="prompt">›</span> checking systems...</p>
            <div className="status-line"><span>Home Assistant</span><strong><i /> ONLINE</strong></div>
            <div className="status-line"><span>Home network</span><strong><i /> HEALTHY</strong></div>
            <div className="status-line"><span>Remote support</span><strong><i /> READY</strong></div>
            <div className="console-rule" />
            <p className="console-result"><span className="prompt">›</span> everything is under control<span className="cursor" /></p>
          </div>
          <div className="console-badge">EST. 2016 <span>—</span> BUILT FROM EXPERIENCE</div>
        </div>
      </section>

      <section className="services-section" id="services"><div className="shell">
        <div className="section-heading"><div><div className="kicker">Services & pricing</div><h2>Pick the help<br />you need.</h2></div><p>No mystery invoices or complicated contracts. Start with one service, change it later, or simply ask what fits.</p></div>
        <div className="service-grid">
          {services.map((service) => <article className={`service-card ${service.featured ? "featured" : ""}`} key={service.name}>
            {service.featured && <div className="popular">BEST VALUE</div>}
            <div className="card-top"><span className={`service-icon ${service.accent}`}>{service.number}</span><span className="arrow" aria-hidden="true">↗</span></div>
            <h3>{service.name}</h3><p className="service-description">{service.description}</p>
            <div className="price"><strong>{service.price}</strong><span>{service.cadence}</span></div>
            <ul>{service.features.map((feature) => <li key={feature}><span>✓</span>{feature}</li>)}</ul>
            <a className="card-button" href={bookingHref(service.name)}>Choose this service <span aria-hidden="true">→</span></a>
          </article>)}
        </div>
        <p className="pricing-note">Not sure which option fits? <a href={bookingHref("a custom IT project")}>Describe your setup</a> and I’ll point you in the right direction.</p>
      </div></section>

      <section className="process shell" id="process">
        <div className="process-intro"><div className="kicker">How it works</div><h2>Useful help.<br />Zero runaround.</h2><p>You don’t need the right technical words. Just tell me what you want to work better.</p></div>
        <ol className="steps">{steps.map(([title, text], index) => <li key={title}><span className="step-number">0{index + 1}</span><div><h3>{title}</h3><p>{text}</p></div></li>)}</ol>
      </section>

      <section className="cta-section"><div className="cta shell">
        <div><div className="eyebrow light"><span className="status-dot" /> Currently taking new clients</div><h2>Ready for tech that<br /><em>just works?</em></h2></div>
        <div className="cta-action"><p>Tell me what you’re dealing with. I’ll reply with a straightforward next step.</p><a className="button button-light" href={bookingHref()}>Start a conversation <span aria-hidden="true">↗</span></a></div>
      </div></section>

      <footer className="footer shell"><a className="brand" href="#top"><span className="brand-mark">NC</span><span>Natural Carr</span></a><p>Freelance IT support for homes and small setups.</p><a href="mailto:hello@naturalcarr.com">hello@naturalcarr.com</a><span>© {new Date().getFullYear()} Natural Carr</span></footer>
    </main>
  );
}
