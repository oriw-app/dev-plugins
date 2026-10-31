---
name: ddd-hexagonal
description: Domain-driven design with hexagonal architecture and command-query separation. Use when modelling a feature, writing a spec's Domain or Design section, adding or moving code between domain, application and adapters, naming things, or reviewing architecture.
---

# DDD, hexagonal architecture and CQS

## Language
- Use the project glossary's words (`domainDoc` in `.claude/sdlc.json`) in issues, scenarios, code and UI text. A new concept gets a glossary entry, in the same pull request, before code uses it.
- Each feature belongs to one bounded context; work that crosses contexts names the contexts and the interface between them.

## Layers, per bounded context
- **Domain:** aggregates, value objects, domain events, rules. Depends on nothing outside itself: no files, network, clock, threads, randomness, frameworks or UI.
- **Application:** one handler per use case; declares **ports** (interfaces) for what it needs: repositories, clock, id generator, transports, AI providers, event publisher.
- **Adapters:** inbound (UI, API, CLI, agent and MCP tools) call handlers; outbound (storage, network, providers) implement ports.
- **Composition root:** the only place adapters are built and plugged into ports.
- Dependencies point inwards only. Respect the project's enforcement (separate core packages, import rules).

## CQS
- A **command** changes state and returns only success or a domain error. It never returns data. Ids are passed in or come from an id-generator port.
- A **query** returns data and changes nothing.
- Commands emit **domain events**; other contexts and **read models** react to events, never by reaching into an aggregate.
- Every actor (people, AI agents, outside tools, sync) goes through the same commands.

## Aggregates
- One aggregate is one consistency boundary; change it only through its own methods.
- Reference other aggregates by id, not by holding them.
