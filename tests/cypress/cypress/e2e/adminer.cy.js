it('AdminerEVO available', () => {

    cy.visit('/adminer');

    cy.contains('AdminerEvo');
    cy.contains('Login');
})

it('AdminerEVO Login works', () => {

    cy.visit('/adminer');

    cy.get(':nth-child(2) > td > input').type('127.0.0.1');
    cy.get('#username').type('root');
    cy.get(':nth-child(4) > td > input').type('root');

    cy.get('p > [type="submit"]').click();

    cy.contains('MySQL version: 8.0.');
})

