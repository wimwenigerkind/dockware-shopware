it('Pimp my Log is available', () => {

    cy.visit('/logs');

    cy.contains('No log has been found with regular search');
})
