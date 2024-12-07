it('MailCatcher available', () => {

    cy.visit('/mailcatcher');

    cy.contains('MailCatcher');
})
